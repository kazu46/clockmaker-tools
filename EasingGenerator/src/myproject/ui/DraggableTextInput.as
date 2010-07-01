package myproject.ui
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.IME;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	import mx.core.UIComponent;
	
	/**
	 * 値が変更された直後に送出されます。
	 * @eventType flash.events.Event.CHANGE
	 */
	[Event(name="change", type="flash.events.Event")]
	/**
	 * DraggableTextInput クラスはスライダーと直接入力の両方をサポートする数値入力インターフェースです。
	 * @author yasu
	 * @see http://clockmaker.jp/
	 *
	 */
	public class DraggableTextInput extends UIComponent
	{
		protected static const TEXTFORMAT_DEFAUT:TextFormat = new TextFormat("Arial", 11, 0x157bbe, null, null, true);
		protected static const TEXTFORMAT_SLIDING:TextFormat = new TextFormat("Arial", 11, 0xFFFFFF, null, null, true);
		protected static const TEXTFORMAT_INPUT:TextFormat = new TextFormat("Arial", 11, 0x000000, null, null, false);
		protected static const TEXTFIELD_HEIGHT:Number = 21;
		protected static const TEXTFIELD_WIDTH:Number = 50;
		
		/**
		 * 新しい DraggableTextInput インスタンスを作成します。
		 */
		public function DraggableTextInput()
		{
			this.__initialize();
		}
		
		/**
		 * ゼロ以外の場合、有効値は、このプロパティの整数倍と minimum の合計および maximum 以下になります。
		 * @return
		 *
		 */
		public function get snapInterval():Number
		{
			return _snapInterval;
		}
		
		public function set snapInterval(value:Number):void
		{
			if (value == 0)
				throw new Error();
			
			_snapInterval = value;
		}
		
		/**
		 * value の有効な最大値です。
		 */
		public function get maximum():Number
		{
			return _maximum;
		}
		
		public function set maximum(value:Number):void
		{
			_maximum = value;
			_value = Math.min(_maximum, _value);
		}
		
		/**
		 * value の有効な最少値です。
		 */
		public function get minimum():Number
		{
			return _minimum;
		}
		
		public function set minimum(value:Number):void
		{
			_minimum = value;
			_value = Math.max(_minimum, _value);
		}
		
		/**
		 * この範囲の現在の値です。
		 */
		public function get value():Number
		{
			return Number(_label.text);
		}
		
		public function set value(value:Number):void
		{
			_value = Math.max(_minimum, Math.min(_maximum, value));
			
			_label.text = _format(_value);
		}
		
		/**
		 * 桁揃えの桁の数値です。
		 */
		public var formatRatio:int = -2;
		
		protected var _value:Number;
		protected var _label:TextField;
		protected var _bg:Shape;
		protected var _pointDown:Point;
		protected var _focusShape:Shape;
		protected var _valueOld:Number;
		protected var _minimum:Number = int.MIN_VALUE;
		protected var _maximum:Number = int.MAX_VALUE;
		protected var _snapInterval:Number = 1;
		protected var _isMouseDown:Boolean;
		protected var _isMouseMove:Boolean;
		private var _arrow:Bitmap;
		
		/**
		 * ユーザーがスライダサムをドラッグしている間、Event.CHANGE イベントが継続的に送出されるかどうかを示すブール値を取得または設定します。
		 * liveDragging プロパティが false の場合、ユーザーがスライダサムを離したときに、Event.CHANGE イベントが送出されます。
		 */		
		public var liveDragging:Boolean;
		
		/**
		 * インスタンスが保持しているデータを破棄します。
		 */
		public function finalize():void
		{
			_arrow.bitmapData.dispose();
			_arrow.bitmapData = null;
			_label.removeEventListener(Event.CHANGE, _onLabelChange);
			removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			removeEventListener(MouseEvent.CLICK, _onClick);
		}
		
		protected function __initialize():void
		{
			_bg = new Shape();
			addChild(_bg);
			
			_focusShape = new Shape();
			_focusShape.graphics.beginFill(0x53b6f9);
			_focusShape.graphics.drawRect(0, 0, 5, 5);
			_focusShape.graphics.endFill();
			_focusShape.graphics.beginFill(0x737373);
			_focusShape.graphics.drawRect(1, 1, 3, 3);
			_focusShape.graphics.endFill();
			_focusShape.graphics.beginFill(0xFFFFFF);
			_focusShape.graphics.drawRect(2, 2, 1, 1);
			_focusShape.graphics.endFill();
			_focusShape.scale9Grid = new Rectangle(2, 2, 1, 1);
			addChild(_focusShape);
			
			_focusShape.width = TEXTFIELD_WIDTH;
			_focusShape.height = TEXTFIELD_HEIGHT;
			_focusShape.visible = false;
			
			_label = new TextField();
			_label.type = TextFieldType.DYNAMIC;
			_label.selectable = false;
			_label.x = 2;
			_label.y = 2;
			_label.width = TEXTFIELD_WIDTH - 4;
			_label.height = TEXTFIELD_HEIGHT - 4;
			_label.restrict = "0-9.\\-";
			_label.addEventListener(Event.CHANGE, _onLabelChange);
			addChild(_label);
			
			// use http://wonderfl.net/c/8TK2
			var arr:Array = [
				[0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0],
				[0, 0, 2, 1, 2, 0, 0, 0, 0, 0, 2, 1, 2, 0, 0],
				[0, 2, 1, 1, 2, 2, 2, 0, 2, 2, 2, 1, 1, 2, 0],
				[2, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 2],
				[0, 2, 1, 1, 2, 2, 2, 0, 2, 2, 2, 1, 1, 2, 0],
				[0, 0, 2, 1, 2, 0, 0, 0, 0, 0, 2, 1, 2, 0, 0],
				[0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0]
			];
			var bmd:BitmapData = new BitmapData(15, 7, true, 0x0);
			bmd.lock();
			for (var i:int = 0; i < arr.length; i++)
			{
				for (var j:int = 0; j < arr[i].length; j++)
				{
					bmd.setPixel32(j, i, arr[i][j] == 0 ? 0x0 : arr[i][j] == 1 ? 0xFF000000 : 0xFFFFFFFF);
				}
			}
			bmd.unlock();
			
			_arrow = new Bitmap(bmd);
			
			_label.defaultTextFormat = TEXTFORMAT_DEFAUT;
			
			addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			addEventListener(MouseEvent.CLICK, _onClick);
		}
		
		protected function _onClick(event:MouseEvent):void
		{
			if (_isMouseDown)
				return;
			
			if (_focusShape.visible == true)
				return;
			
			if (Capabilities.hasIME)
			{
				try
				{
					IME.enabled = false;
				}
				catch (error:Error)
				{
				}
			}
			
			_valueOld = Number(_label.text);
			_label.type = TextFieldType.INPUT;
			_label.selectable = true;
			_label.setSelection(0, _label.length);
			_label.defaultTextFormat = TEXTFORMAT_INPUT;
			_label.text = _label.text;
			
			_focusShape.visible = true;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownForCommit);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
		}
		
		protected function _onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.ENTER:
					_commitProperties();
					break;
				case Keyboard.ESCAPE:
					_label.text = _valueOld.toString(10);
					_commitProperties();
					break;
				case Keyboard.UP:
					_updateValue(Number(_label.text) + _snapInterval);
					_label.setSelection(0, _label.length);
					break;
				case Keyboard.DOWN:
					_updateValue(Number(_label.text) - _snapInterval);
					_label.setSelection(0, _label.length);
					break;
			}
		}
		
		protected function _onMouseDownForCommit(event:MouseEvent):void
		{
			if (event.target == _label)
				return;
			
			_commitProperties();
		}
		
		protected function _commitProperties():void
		{
			var valueNew:Number = Number(_label.text);
			if (valueNew < _minimum || valueNew > _maximum)
			{
				valueNew = _valueOld;
			}
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownForCommit);
			
			_label.defaultTextFormat = TEXTFORMAT_DEFAUT;
			_label.selectable = false;
			_label.type = TextFieldType.DYNAMIC;
			_label.text = _format(valueNew)
			
			_focusShape.visible = false;
			
			_dispatchChangeEvent();
		}
		
		protected function _onMouseDown(event:MouseEvent):void
		{
			if (_label.type == TextFieldType.INPUT)
				return;
			
			stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			
			_label.defaultTextFormat = TEXTFORMAT_SLIDING;
			
			_label.text = _label.text;
			_pointDown = new Point(mouseX, mouseY);
			
			_valueOld = Number(_label.text);
			
			_bg.graphics.clear();
			_bg.graphics.beginFill(0x157bbe);
			_bg.graphics.drawRect(0, 0, _label.textWidth + 8, TEXTFIELD_HEIGHT);
			
			Mouse.hide();
			stage.addChild(_arrow);
			_arrow.visible = true;
			
			_arrow.x = stage.mouseX　- int( _arrow.width / 2 );
			_arrow.y = stage.mouseY　- int( _arrow.height / 2);
			
			_isMouseDown = false;
			_isMouseMove = false;
		}
		
		protected function _onMouseMove(event:MouseEvent):void
		{
			_isMouseMove = true;
			
			var vx:Number = +1 * (mouseX - _pointDown.x);
			var vy:Number = -1 * (mouseY - _pointDown.y);
			var d:Number = (vx + vy) * _snapInterval;
			
			_updateValue(_valueOld + d);
			
			_bg.graphics.clear();
			_bg.graphics.beginFill(0x157bbe);
			_bg.graphics.drawRect(0, 0, _label.textWidth + 8, TEXTFIELD_HEIGHT);
			
			if(liveDragging)
			{
				_dispatchChangeEvent();
			}
			
			_arrow.x = stage.mouseX　- int( _arrow.width / 2 );
			_arrow.y = stage.mouseY　- int( _arrow.height / 2 );
			
			if(
				stage.mouseX > stage.stageWidth
				|| stage.mouseX < 0
				|| stage.mouseY > stage.stageHeight
				|| stage.mouseY < 0
			)
			{
				if(_arrow.visible)
				{
					Mouse.show();
					_arrow.visible = false;
				}
			}
			else
			{
				if(!_arrow.visible)
				{
					Mouse.hide();
					_arrow.visible = true;
				}
			}
			
			
			event.updateAfterEvent();
		}
		
		protected function _updateValue(valueNew:Number):void
		{
			valueNew = Math.max(_minimum, Math.min(_maximum, valueNew));
			_label.text = _format(valueNew);
		}
		
		protected function _onMouseUp(event:MouseEvent):void
		{
			_bg.graphics.clear();
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			
			_label.defaultTextFormat = TEXTFORMAT_DEFAUT;
			_label.text = _label.text;
			
			if (event.target == _label && _isMouseMove)
				_isMouseDown = true;
			
			Mouse.show();
			if(stage.contains(_arrow))
				stage.removeChild(_arrow);
			
			_dispatchChangeEvent();
		}
		
		/**
		 * 値をフォーマットします。
		 * @param val フォーマットしたい値。
		 * @return フォーマットされた文字列。
		 */
		protected function _format(val:Number):String
		{
			var nn:Number = Math.pow(10, formatRatio);
			var valueNew:Number = Math.round(val / nn) * nn;
			
			var str:String = valueNew.toString(10);
			var arr:Array = str.split(".");
			
			var decimal:String = arr[1] || "00";
			var ratio:Number = Math.abs(formatRatio);
			if (decimal.length < ratio)
			{
				while (decimal.length < ratio)
				{
					decimal = decimal + "0";
				}
			}
			else
			{
				decimal = decimal.substr(0, ratio);
			}
			if (ratio == 0)
				decimal = "0";
			
			return arr[0] + "." + decimal;
		}
		
		protected function _dispatchChangeEvent():void
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function _onLabelChange(event:Event):void
		{
			event.stopPropagation();
		}
	}
}