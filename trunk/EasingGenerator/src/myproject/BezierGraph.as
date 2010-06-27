package myproject
{
	import com.bit101.components.Label;
	
	import fl.motion.BezierSegment;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.managers.PopUpManager;
	
	import myproject.assets.EmbedText;
	import myproject.data.Preset;
	import myproject.data.PresetData;
	import myproject.preview.MoveMonitor;
	import myproject.preview.RotateMonitor;
	import myproject.preview.ScaleMonitor;
	import myproject.ui.AlertWindow;
	
	import org.libspark.betweenas3.core.easing.IEasing;
	import org.libspark.betweenas3.easing.Custom;

	/**
	 * BezierGraphクラスはベジェ曲線編集用のパネルです。
	 * @author yasu
	 */
	public class BezierGraph extends Sprite
	{
		/**
		 * グラフの矩形領域です。
		 */
		public static const GRAPH_RECT:Rectangle = new Rectangle(35, 10, GRAPH_STEP_W * 24, GRAPH_STEP_H * 20);

		/**
		 * 0〜100%の領域を示すグラフの矩形領域です。
		 */
		public static const PERCENT_RECT:Rectangle = new Rectangle(0, GRAPH_STEP_H * 4, GRAPH_STEP_W * 24, GRAPH_STEP_H * 12);

		/**
		 * シングルトン参照です。
		 */
		public static var instance:BezierGraph;

		private static const GRAPH_STEP_W:Number = 24;
		private static const GRAPH_STEP_H:Number = 17;

		/**
		 * 新しい BezierGraph インスタンスを作成します。
		 */
		public function BezierGraph()
		{
			instance = this;

			_monitorMove = new MoveMonitor();
			_monitorMove.x = 70;
			_monitorMove.y = 390;
			addChild(_monitorMove);

			_monitorScale = new ScaleMonitor();
			_monitorScale.x = 520;
			_monitorScale.y = 390;
			addChild(_monitorScale);

			_monitorRotate = new RotateMonitor();
			_monitorRotate.x = 620;
			_monitorRotate.y = 390;
			addChild(_monitorRotate);

			_container.addChild(_division);
			_container.addChild(_canvas);
			addChild(_container);

			_debugCanvas = new Shape();
			_debugCanvas.x = GRAPH_RECT.left + PERCENT_RECT.left;
			_debugCanvas.y = GRAPH_RECT.top;
			addChild(_debugCanvas);
			
			_curveCanvas = new Shape();
			_curveCanvas.x = GRAPH_RECT.left + PERCENT_RECT.left;
			_curveCanvas.y = GRAPH_RECT.top + PERCENT_RECT.top;
			addChild(_curveCanvas);
			_curveCanvas.filters = [new DropShadowFilter(1, 90, 0, 0.4, 0, 2)];
			

			_clickCanvas = new Sprite();
			_clickCanvas.x = GRAPH_RECT.left + PERCENT_RECT.left;
			_clickCanvas.y = GRAPH_RECT.top + PERCENT_RECT.top;
			_clickCanvas.buttonMode = true;
			_clickCanvas.addEventListener(MouseEvent.MOUSE_DOWN, _onCanvasMouseDown);
			addChild(_clickCanvas);

			_controlCanvas = new Sprite();
			_controlCanvas.x = GRAPH_RECT.left + PERCENT_RECT.left;
			_controlCanvas.y = GRAPH_RECT.top + PERCENT_RECT.top;
			addChild(_controlCanvas);

			reset(Preset.presetAC.getItemAt(0) as PresetData);
			_drawDivision();
			initUI();
			_updateEase();

			_update(null);
		}

		public var engine:String = "Tweener";

		private var _clickCanvas:Sprite;
		private var _container:Sprite = new Sprite();
		private var _canvas:Sprite = new Sprite();
		private var _division:Shape = new Shape();
		private var _controls:Vector.<BezierPoint>;
		private var _controlCanvas:Sprite = new Sprite();
		private var _curveCanvas:Shape;
		private var _debugCanvas:Shape;
		private var _monitorMove:MoveMonitor;
		private var _monitorScale:ScaleMonitor;
		private var _monitorRotate:RotateMonitor;
		private var _currentPoint:BezierPoint;

		/**
		 * プレビューを停止します。
		 *
		 */
		public function stopPreview():void
		{
			_monitorMove.tween.stop();
			_monitorRotate.tween.stop();
			_monitorScale.tween.stop();
		}

		/**
		 * プレビューを再生します。
		 *
		 */
		public function playPreview():void
		{
			_monitorMove.tween.stopOnComplete = true;
			_monitorRotate.tween.stopOnComplete = true;
			_monitorScale.tween.stopOnComplete = true;

			_monitorMove.tween.gotoAndPlay(0);
			_monitorRotate.tween.gotoAndPlay(0);
			_monitorScale.tween.gotoAndPlay(0);
		}

		/**
		 * プレビューをループ再生します。
		 *
		 */
		public function playPreviewLoop():void
		{
			_monitorMove.tween.stopOnComplete = false;
			_monitorRotate.tween.stopOnComplete = false;
			_monitorScale.tween.stopOnComplete = false;

			_monitorMove.tween.gotoAndPlay(0);
			_monitorRotate.tween.gotoAndPlay(0);
			_monitorScale.tween.gotoAndPlay(0);
		}

		/**
		 * ポイントを削除します。
		 * @param target
		 */
		public function deletePoint(target:BezierPoint):void
		{
			var index:int = _controls.indexOf(target);
			_controls.splice(index, 1);
			_controlCanvas.removeChild(target);

			_update(null);
		}

		/**
		 * リセットします。
		 */
		public function reset(preset:PresetData):void
		{
			var i:int;
			if (_controls)
			{
				for (i = 0; i < _controls.length; i++)
				{
					_controls[i].removeEventListener(Event.CHANGE, _onChange);
					_controls[i].destroy();
					_controlCanvas.removeChild(_controls[i]);
				}
			}

			_controls = new Vector.<BezierPoint>();
			var controls:Array = preset.data;
			for (i = 0; i < controls.length; i++)
			{
				var lock:Boolean = i == 0 || i == controls.length - 1;
				var pre:Point = controls[i].pre
					? new Point(controls[i].pre[0], controls[i].pre[1])
					: null;
				var post:Point = controls[i].post
					? new Point(controls[i].post[0], controls[i].post[1])
					: null;
				_controls[i] = new BezierPoint(
					new Point(controls[i].point[0], controls[i].point[1]),
					lock, pre, post
					);
			}

			for (i = 0; i < _controls.length; i++)
			{
				_controls[i].addEventListener(Event.CHANGE, _onChange);
				_controlCanvas.addChild(_controls[i]);
			}


			_update(null);
			
//			_debugDraw(preset.func);
		}

		public function getDragbleRect(target:BezierPoint):Rectangle
		{
			var index:uint = _controls.indexOf(target);

			var rect:Rectangle = new Rectangle(
				_controls[index - 1].x,
				-PERCENT_RECT.top,
				_controls[index + 1].x - _controls[index - 1].x,
				GRAPH_RECT.height);

			return rect;
		}

		public function copy():String
		{
			var str:String = "";

			for (var i:int = 0; i < _controls.length; i++)
			{
				var c:BezierPoint = _controls[i];
				str += '\t\t{point:[' + _digit(c.toNormalPoint().x) + ',' + _digit(c.toNormalPoint().y)
					+ '],pre:[' + _digit(c.controlPointPreNormaled.x) + ',' + _digit(c.controlPointPreNormaled.y)
					+ '],post:[' + _digit(c.controlPointPostNormaled.x) + ',' + _digit(c.controlPointPostNormaled.y) + "]},\n"
			}

			if (engine == "Tweener")
				str = new EmbedText.CODE_PRE_TWEENER + str + new EmbedText.CODE_POST_TWEENER;
			else if (engine == "BetweenAS3")
				str = new EmbedText.CODE_PRE_BETWEENAS3 + str + new EmbedText.CODE_POST_BETWEENAS3;
			else if (engine == "KTween")
				str = new EmbedText.CODE_PRE_KTWEEN + str + new EmbedText.CODE_POST_KTWEEN;
			else if (engine == "TweenMax")
				str = new EmbedText.CODE_PRE_TWEENMAX + str + new EmbedText.CODE_POST_TWEENMAX;

			return str;
		}

		private function _debugDraw(ease:IEasing):void
		{
			_debugCanvas.graphics.clear();
			_debugCanvas.graphics.lineStyle(1, 0xAAAAAA);
			_debugCanvas.graphics.moveTo(PERCENT_RECT.left, PERCENT_RECT.bottom);
			for (var t:Number = 0.0; t <= 1.0; t += 0.01)
			{
				var num:Number = ease.calculate(t, 0.0, 1.0, 1.0);
				_debugCanvas.graphics.lineTo(
					PERCENT_RECT.width * t,
					PERCENT_RECT.bottom - PERCENT_RECT.height * num);
			}
			_debugCanvas.graphics.lineTo(
				PERCENT_RECT.width,
				PERCENT_RECT.bottom - PERCENT_RECT.height);
		}

		private function _digit(value:Number, ratio:Number = 100):Number
		{
			return Math.round(value * ratio) / ratio;
		}

		private function _update(event:Event):void
		{
			var i:int;

			_curveCanvas.graphics.clear();
			_clickCanvas.graphics.clear();

			// bezier init
			_curveCanvas.graphics.moveTo(_controls[0].x, _controls[0].y);
			_curveCanvas.graphics.lineStyle(1, 0x000000);
			_clickCanvas.graphics.moveTo(_controls[0].x, _controls[0].y);
			_clickCanvas.graphics.lineStyle(10, 0xFF0000, 0);

			// bezier loop
			for (i = 0; i < _controls.length - 1; i++)
			{
				var bezier:BezierSegment = new BezierSegment(
					_controls[i].toPoint(),
					_controls[i].controlPointPost,
					_controls[i + 1].controlPointPre,
					_controls[i + 1].toPoint());
				for (var t:Number = 0.0; t <= 1.0; t += 0.01)
				{
					var pt:Point = bezier.getValue(t);
					_curveCanvas.graphics.lineTo(pt.x, pt.y);
					_clickCanvas.graphics.lineTo(pt.x, pt.y);
				}
			}
		}

		private function _onCanvasMouseDown(event:MouseEvent):void
		{
			var p:Point = new Point(
				_controlCanvas.mouseX / PERCENT_RECT.width,
				1 - _controlCanvas.mouseY / PERCENT_RECT.height);

			_currentPoint = new BezierPoint(new Point(p.x, p.y), false, new Point(p.x, p.y), new Point(p.x, p.y));
			_currentPoint.addEventListener(Event.CHANGE, _onChange);
			_controlCanvas.addChild(_currentPoint);
			_controls.push(_currentPoint);

			_controls.sort(function(a:BezierPoint, b:BezierPoint):Number{
					return a.x - b.x;
				});

			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onCanvasMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onCanvasMouseUp);
		}

		private function _onCanvasMouseMove(event:MouseEvent):void
		{
			_currentPoint.updateControlPoint(_controlCanvas.mouseX, _controlCanvas.mouseY);
			_update(null);
			event.updateAfterEvent();
		}

		private function _onCanvasMouseUp(event:MouseEvent):void
		{
			_currentPoint = null;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onCanvasMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onCanvasMouseUp);
		}

		private function _onChange(event:Event):void
		{
			var t:BezierPoint = (event.currentTarget as BezierPoint);
			t.tx = t.x / GRAPH_RECT.width;
			t.ty = (GRAPH_RECT.height - t.y) / GRAPH_RECT.height;

			_update(null);
		}

		/**
		 * トゥイーンを作成
		 */
		private function _updateEase():void
		{
			// カスタムイージングを作成
			var ease:IEasing = Custom.func(function(t:Number, b:Number, c:Number, d:Number):Number{
					var time:Number = t / d;

					var i:int = 0;
					var bezier:BezierSegment = null;
					for (i = 0; i < _controls.length - 1; i++)
					{
						if (time >= _controls[i].toNormalPoint().x && time <= _controls[i + 1].toNormalPoint().x)
						{
							bezier = new BezierSegment(
								_controls[i].toNormalPoint(),
								_controls[i].controlPointPostNormaled,
								_controls[i + 1].controlPointPreNormaled,
								_controls[i + 1].toNormalPoint());

							break;
						}
					}

					return c * bezier.getYForX(t / d) + b;
				});

			_monitorMove.initTween(ease);
			_monitorScale.initTween(ease);
			_monitorRotate.initTween(ease);
		}

		private function initUI():void
		{
			var l:Label = new Label(this, 8, 190, "TWEEN");
			l.rotation = -90;
			new Label(this, 295, 360, "TIME (0.0 - 1.0)");
		}

		private function drawLine(p0:Point, p1:Point, color:uint = 0x000000):void
		{
			_canvas.graphics.lineStyle(1, color);
			_canvas.graphics.moveTo(p0.x, p0.y);
			_canvas.graphics.lineTo(p1.x, p1.y);
			_canvas.graphics.lineStyle();
		}

		private function _drawDivision():void
		{
			_division.graphics.beginFill(0xE6E6E6);
			_division.graphics.drawRect(0, 0, GRAPH_RECT.width, GRAPH_RECT.height);
			_division.graphics.endFill();

			_division.graphics.lineStyle(1, 0xB3B3B3);
			for (var i:int = 0; i <= GRAPH_RECT.width; i++)
			{
				if (i % GRAPH_STEP_W == 0)
				{
					_division.graphics.moveTo(i, 0);
					_division.graphics.lineTo(i, GRAPH_RECT.height);
				}
				if (i != 0 && i % Math.round(GRAPH_RECT.width / 10) == 0)
				{
					var num:Number = Math.floor(i / GRAPH_RECT.width * 10) / 10;
					new Label(_container, i + GRAPH_RECT.left - 10, GRAPH_RECT.bottom - 20, num.toString(10));
				}
			}
			for (var j:int = 0; j <= GRAPH_RECT.height; j++)
			{
				if (j % GRAPH_STEP_H == 0)
				{
					_division.graphics.moveTo(0, j);
					_division.graphics.lineTo(GRAPH_RECT.width, j);
				}

				if (j != GRAPH_RECT.height && (j / GRAPH_RECT.height * 100) % 10 == 0)
				{
					new Label(
						_container,
						38,
						j + GRAPH_RECT.top + 3,
						Math.round((1 - 2 * j / GRAPH_RECT.height) * 100) + 40 + "%");
				}
			}

			_division.graphics.lineStyle(1, 0x808080);
			_division.graphics.moveTo(0, PERCENT_RECT.top);
			_division.graphics.lineTo(GRAPH_RECT.width, PERCENT_RECT.top);
			_division.graphics.moveTo(0, PERCENT_RECT.bottom);
			_division.graphics.lineTo(GRAPH_RECT.width, PERCENT_RECT.bottom);
			_division.graphics.lineStyle(1, 0xFFFFFFF);
			_division.graphics.moveTo(0, PERCENT_RECT.top + 1);
			_division.graphics.lineTo(GRAPH_RECT.width, PERCENT_RECT.top + 1);
			_division.graphics.moveTo(0, PERCENT_RECT.bottom + 1);
			_division.graphics.lineTo(GRAPH_RECT.width, PERCENT_RECT.bottom + 1);

			_division.x = GRAPH_RECT.x;
			_division.y = GRAPH_RECT.y;
		}
	}
}
