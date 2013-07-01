/*
 * LoadManager by Yasunobu Ikeda. April 20, 2010
 * Visit http://clockmaker.jp/ for documentation, updates and examples.
 *
 *
 * Copyright (c) 2010 Yasunobu Ikeda
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

if (this.lmlib == undefined) {
	/**
	 * @namespace LoadManagerの内部でしかつかわないクラスのための名前空間です。
	 */
	lmlib = {};
}


/**
 * 読み込みアイテムのバリューオブジェクトです。
 * @param {String} url  URLです。
 * @param {Ojbect} extra 任意のObjectデータです。
 * @constructor
 * @author Yasunobu Ikeda ( http://clockmaker.jp )
 */
lmlib.LoadingData = function (url, extra) {
	/**
	 * URLです。
	 * @type String
	 */
	this.url = url;
	/**
	 * エキストラオブジェクト(何でも保持可能)です。
	 * @type Object
	 */
	this.extra = extra;

	/**
	 * Image オブジェクトです。
	 * @type Image
	 */
	this.image = null;
}


/**
 * LoadManager の完了イベントを定義したイベントクラスです。
 * ネイティブのEventクラスの継承ではありませんので注意ください。
 * @author Yasunobu Ikeda ( http://clockmaker.jp )
 * @constructor
 */
lmlib.CompleteEvent = function () {
}

lmlib.CompleteEvent.prototype = {
	/**
	 * イベントターゲットです。
	 * @type LoadManager
	 */
	target:null
};


/**
 * LoadManager のプログレスイベントを定義したイベントクラスです。
 * ネイティブのEventクラスの継承ではありませんので注意ください。
 * @constructor
 * @author Yasunobu Ikeda ( http://clockmaker.jp )
 */
lmlib.ProgressEvent = function () {
	/**
	 * Number of items already loaded
	 * @type Number
	 */
	this.itemsLoaded = 0;
	/**
	 * Number of items to be loaded
	 * @type Number
	 */
	this.itemsTotal = 0;
	/**
	 * The ratio (0-1) loaded (number of items loaded / number of items total)
	 * @type Number
	 */
	this.percent = 0;
	/**
	 * 読み込み処理に関するデータオブジェクトです。
	 * @type lmlib.LoadingData
	 */
	this.data = null;
	/**
	 * イベントターゲットです。
	 * @type LoadManager
	 */
	this.target = null;
}


/**
 * LoadManager のエラーイベントを定義したイベントクラスです。
 * ネイティブのEventクラスの継承ではありませんので注意ください。
 * @constructor
 * @author Yasunobu Ikeda ( http://clockmaker.jp )
 */
lmlib.ErrorEvent = function () {
	/**
	 * 読み込み処理に関するデータオブジェクトです。
	 * @type lmlib.LoadingData
	 */
	this.data = null;
	/**
	 * イベントターゲットです。
	 * @type LoadManager
	 */
	this.target = null;
}


/**
 * LoadManager は Image オブジェクトの読み込みを管理するクラスです。.
 * @version 2.0.0 alpha
 * @author Yasunobu Ikeda ( http://clockmaker.jp )
 * @constructor
 */
function LoadManager() {
	this.initialize();
}

/**
 *  LogLevel: すべてのログを出力します。
 *  @type Number
 *  @constant
 */
LoadManager.LOG_VERBOSE = 0;
/**
 * LogLevel: ログは一切出力しません。
 * @type Number
 * @constant
 */
LoadManager.LOG_SILENT = 10;
/**
 * LogLevel: エラーのときだけログを出力します。
 * @type Number
 * @constant
 */
LoadManager.LOG_ERRORS = 4;

/**
 * スコープを移譲した関数を作成します。
 * @param {Function} func 実行したい関数
 * @param {Object} thisObj 移譲したいスコープ
 * @return {Function} 移譲済みの関数
 * @private
 */
LoadManager._delegate = function (func, thisObj) {
	var del = function () {
		return func.apply(thisObj, arguments);
	};
	//情報は関数のプロパティとして定義する
	del.func = func;
	del.thisObj = thisObj;
	return del;
};

LoadManager.prototype = {

	/** URLリスト */
	_queueArr:null,
	_registerArr:null,
	_successArr:null,
	_errorArr:null,
	_isStarted:false,
	_isRunning:false,
	_isFinished:false,
	_currentQueues:null,
	_queueCount:0,
	/**
	 * 同時接続数です。デフォルトは6です。
	 * @type Number
	 * @default 6
	 */
	numConnections:6,
	/**
	 * プログレスイベント発生時に呼ばれるコールバックです。
	 * @params {lmlib.ProgressEvent} event ProgressEvent オブジェクトが第一引数で渡されます。
	 * @function
	 */
	onProgress:null,
	/**
	 * 処理完了時に呼ばれるコールバックです。
	 * @params {lmlib.CompleteEvent} event CompleteEvent オブジェクトが第一引数で渡されます。
	 * @function
	 */
	onComplete:null,
	/**
	 * エラー発生時に呼ばれるコールバックです。
	 * @params {lmlib.ErrorEvent} event  ErrorEvent オブジェクトが第一引数で渡されます。
	 * @function
	 */
	onError:null,
	/**
	 * ログのレベルを取得または設定します。デフォルトは LOG_SILENT (出力なし) です。
	 * @type Number
	 */
	logLevel:LoadManager.LOG_SILENT,

	/**
	 * コンストラクタです。
	 */
	initialize: function (){
		this._queueArr = [];
		this._registerArr = [];
		this._successArr = [];
		this._errorArr = [];
		this._isStarted = false;
		this._isRunning = false;
		this._isFinished = false;
		this._currentQueues = [];
		this._queueCount = 0;
		this.numConnections = 6;
		this.onProgress = null;
		this.onComplete = null;
		this.onError = null;
		this.logLevel = LoadManager.LOG_SILENT;
	},

	/**
	 * 処理が走っているかどうかを取得します。
	 * @return {Boolean}
	 */
	getIsRunning:function () {
		return this._isRunning;
	},
	/**
	 * 処理が完了しているかどうかを取得します。
	 * @return {Boolean}
	 */
	getIsFinished:function () {
		return this._isFinished;
	},
	/**
	 * 読み込みに成功したアイテムを配列として取得します。
	 * @return {Array} Array of LoadingData
	 */
	getSuccessItems:function () {
		return this._successArr;
	},
	/**
	 * 読み込みに失敗したアイテムを配列として取得します。
	 * @return {Array} Array of LoadingData
	 */
	getFailedItems:function () {
		return this._errorArr;
	},
	/**
	 * 処理の進行度を0～1の値で取得します。 (either IO Error).
	 * @return {Number}
	 */
	getPercent:function () {
		var percent = (this._successArr.length + this._errorArr.length) / this._registerArr.length;
		percent = Math.min(1, Math.max(0, percent));
		return percent;
	},

	/**
	 * 読み込みたいアセットを登録します。
	 * @params {String} url	URLです。
	 * @params {Object} extra	任意の Object データです。
	 * @return {lmlib.LoadingData} 読み込みアイテムの情報です。
	 */
	add:function (url, extra) {
		if (this._isStarted) {
			this._log("既にLoadManagerインスタンスがstartしているため、add()することができません。", LoadManager.LOG_ERRORS);
		}

		var item = new lmlib.LoadingData(url, extra);
		this._registerArr.push(item);
		return item;
	},

	/**
	 * URLをキーとして読み込み済みアセットを取得します。
	 * なるべく読み込み完了後(onCompete発生後)に使ってください。
	 * @param {String} url	URLです。このURLと一致するアセットを返します。
	 * @return {lmlib.LoadingData}	読み込み情報を保持したデータです。
	 */
	get:function (url) {
		for (var i = 0; i < this._registerArr.length; i++) {
			if (this._registerArr[i].url == url) {
				return this._registerArr[i];
			}
		}
		return null;
	},

	/**
	 * 読み込み処理を開始します。
	 * @param {Number} withConnections (default = null) — [optional] 同時読み込み数です。
	 */
	start:function (withConnections) {
		if (this._isStarted) {
			throw "既にLoadManagerインスタンスがstartしているため、start()することができません。";
		}

		if (typeof(withConnections) == "number") {
			this.numConnections = withConnections;
		}

		this._queueArr = this._registerArr.concat();
		this._execute(this._queueArr[0]);
		this._isStarted = true;
	},

	_loadNextImage:function () {
		while (this.numConnections > this._queueCount) {
			if (this._queueArr.length == 0)
				break;

			var nextQueue = this._queueArr.shift();

			// Retrieve next filename in queue
			this._currentQueues.push(nextQueue);

			this._execute(nextQueue);

			this._queueCount++;
		}

		// Busy loading
		this._isRunning = true;
	},

	_execute:function (loadingData) {
		if (loadingData.image == null)
			loadingData.image = new Image();

		var self = this;

		// Already loaded
		loadingData.image.onload = function () {
			self._log("[LM - Success] " + loadingData.url, LoadManager.LOG_VERBOSE);

			self._successArr.push(loadingData);

			if (typeof(loadingData.callbackFunc) == "function") {
				loadingData.callbackFunc(loadingData.image);
			}

			// Remove from queue
			self._queueCount--;

			// dispatch Event
			if (typeof(self.onProgress) == "function") {
				var event = new lmlib.ProgressEvent();
				event.target = self;
				event.itemsLoaded = self._successArr.length;
				event.itemTotal = self._registerArr.length;
				event.percent = self.getPercent();
				event.data = loadingData;
				self.onProgress(event);
			}

			// Continue loading
			if (!self._checkFinished()) self._delayFunc();
		};

		loadingData.image.onerror = function () {
			self._log("[LM - Error] " + loadingData.url, LoadManager.LOG_VERBOSE);

			// Remove from queue
			self._errorArr.push(loadingData);

			// Remove from queue
			self._queueCount--;

			// dispatch Event
			if (typeof(self.onError) == "function") {
				var event = new lmlib.ErrorEvent();
				event.target = this;
				event.data = loadingData;
				self.onError(event);
			}

			// Continue loading
			if (!self._checkFinished()) self._delayFunc();
		};

		loadingData.image.src = loadingData.url;
	},

	_checkFinished:function () {
		// Queue finished?
		if (this._successArr.length + this._errorArr.length == this._registerArr.length) {
			// Loading finished
			this._isRunning = false;
			this._isFinished = true;

			// dispatch Event
			if (typeof(this.onComplete) == "function") {
				var event = new lmlib.CompleteEvent();
				event.target = this;
				this.onComplete(event);
			}

			return true;
		}
		return false;
	},

	/** delay loading for stack over flow error of IE6 */
	_delayFunc:function () {
		setTimeout(LoadManager._delegate(this._loadNextImage, this), 16);
	},

	_log:function (object, level) {
		if (this.logLevel <= level)
			console.log(object);
	}
};
window.LoadManager = LoadManager;


