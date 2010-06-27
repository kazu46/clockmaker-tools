package myproject
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import myproject.impl.IDestroyable;

	/**
	 * BezierPointクラスは、ベジェの制御点です。
	 * @author yasu
	 *
	 */
	public class BezierPoint extends Sprite implements IDestroyable
	{
		private static const COLOR:int = 0x0;
		private static const RADIUS:int = 4;
		private static const SNAP_HEIGHT:uint = 14;
		private static const FIT_HEIGHT:uint = 4;


		/**
		 * @inheritDoc
		 */
		public function destroy():void
		{
			_main.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			_controlPre.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			_controlPost.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
		}

		/**
		 * 新しい BezierPoint インスタンスを作成します。
		 */
		public function BezierPoint(main:Point, lock:Boolean, pointPre:Point, pointPost:Point):void
		{
			this.lock = lock;
			this.pointPre = pointPre;
			this.pointPost = pointPost;

			_main = new Sprite();
			_main.graphics.beginFill(COLOR, 0);
			_main.graphics.drawRect(-SNAP_HEIGHT/2, -SNAP_HEIGHT/2, SNAP_HEIGHT, SNAP_HEIGHT);
			_main.graphics.endFill();
			_main.graphics.beginFill(0x5083fc);
			_main.graphics.drawRect(-RADIUS / 2 >> 0, -RADIUS / 2 >> 0, RADIUS, RADIUS);
			_main.graphics.endFill();
			addChild(_main);
			
			if(!lock){
				_main.buttonMode = true;
				var menu:ContextMenu = new ContextMenu();
				var contextMenuItem:ContextMenuItem = new ContextMenuItem("Delete");
				contextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _onMenuItemSelect);
				menu.customItems = [contextMenuItem];
				_main.contextMenu = menu;
			}

			_controlPre = new Sprite();
			_controlPre.graphics.beginFill(COLOR, 0);
			_controlPre.graphics.drawRect(-SNAP_HEIGHT/2, -SNAP_HEIGHT/2, SNAP_HEIGHT, SNAP_HEIGHT);
			_controlPre.graphics.endFill();
			_controlPre.graphics.lineStyle(1, 0x5083fc);
			_controlPre.graphics.beginFill(0xFFFFFF);
			_controlPre.graphics.drawRect(-RADIUS / 2 >> 0, -RADIUS / 2 >> 0, RADIUS, RADIUS);
			_controlPre.graphics.endFill();
			_controlPre.buttonMode = true;
			if (pointPre)
				addChild(_controlPre);

			_controlPost = new Sprite();
			_controlPost.graphics.beginFill(COLOR, 0);
			_controlPost.graphics.drawRect(-SNAP_HEIGHT/2, -SNAP_HEIGHT/2, SNAP_HEIGHT, SNAP_HEIGHT);
			_controlPost.graphics.endFill();
			_controlPost.graphics.lineStyle(1, 0x5083fc);
			_controlPost.graphics.beginFill(0xFFFFFF);
			_controlPost.graphics.drawRect(-RADIUS / 2 >> 0, -RADIUS / 2 >> 0, RADIUS, RADIUS);
			_controlPost.graphics.endFill();
			_controlPost.buttonMode = true;
			if (pointPost)
				addChild(_controlPost);

			this.x = main.x * (BezierGraph.PERCENT_RECT.width);
			this.y = (1 - main.y) * (BezierGraph.PERCENT_RECT.height);

			if (pointPre)
			{
				_controlPre.x = pointPre.x * (BezierGraph.PERCENT_RECT.width) - this.x;
				_controlPre.y = (1 - pointPre.y) * (BezierGraph.PERCENT_RECT.height) - this.y;
			}
			if (pointPost)
			{
				_controlPost.x = pointPost.x * (BezierGraph.PERCENT_RECT.width) - this.x;
				_controlPost.y = (1 - pointPost.y) * (BezierGraph.PERCENT_RECT.height) - this.y;
			}

			_main.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			_controlPre.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			_controlPost.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);

			graphics.clear();

			_drawLine(_main, _controlPre);
			_drawLine(_main, _controlPost);
		}

		private function _onMenuItemSelect(event:ContextMenuEvent):void
		{
			BezierGraph.instance.deletePoint(this);
		}

		/**
		 *
		 */
		public var tx:Number;
		/**
		 *
		 */
		public var ty:Number;
		/**
		 *
		 */
		public var pointPre:Point;
		/**
		 *
		 */
		public var pointPost:Point;
		/**
		 * 編集可能かどうかを取得または設定します。
		 */
		public var lock:Boolean;

		/**
		 *
		 * @return
		 *
		 */
		public function get controlPointPre():Point
		{
			return new Point(this.x + _controlPre.x, this.y + _controlPre.y);
		}

		/**
		 *
		 * @return
		 *
		 */
		public function get controlPointPost():Point
		{
			return new Point(this.x + _controlPost.x, this.y + _controlPost.y);
		}

		/**
		 *
		 * @return
		 *
		 */
		public function get controlPointPreNormaled():Point
		{
			return new Point(
				(this.x + _controlPre.x) / BezierGraph.PERCENT_RECT.width,
				(BezierGraph.PERCENT_RECT.height - this.y - _controlPre.y) / BezierGraph.PERCENT_RECT.height);
		}

		/**
		 *
		 * @return
		 *
		 */
		public function get controlPointPostNormaled():Point
		{
			return new Point(
				(this.x + _controlPost.x) / BezierGraph.PERCENT_RECT.width,
				(BezierGraph.PERCENT_RECT.height - this.y - _controlPost.y) / BezierGraph.PERCENT_RECT.height);
		}
		private var _controlPre:Sprite;
		private var _controlPost:Sprite;
		private var _main:Sprite;
		private var _oldPoint:Point;
		private var _currentDrag:Sprite;

		/**
		 *
		 * @return
		 *
		 */
		public function toPoint():Point
		{
			return new Point(this.x, this.y);
		}

		/**
		 *
		 * @return
		 *
		 */
		public function toNormalPoint():Point
		{
			var xx:Number = (this.x) / BezierGraph.PERCENT_RECT.width;
			var yy:Number = (BezierGraph.PERCENT_RECT.height - this.y) / BezierGraph.PERCENT_RECT.height;

			return new Point(xx, yy);
		}

		private function _onMouseDown(event:MouseEvent):void
		{
			var rect:Rectangle;
			switch (event.currentTarget)
			{
				case _main:
					if (lock)
						return;
					_currentDrag = this;
					_currentDrag.startDrag(true, BezierGraph.instance.getDragbleRect(this));
					break;
				case _controlPre:
					_currentDrag = _controlPre;
					rect = new Rectangle(
							-this.x, 
							-this.y - BezierGraph.PERCENT_RECT.top, 
							this.x, 
							BezierGraph.GRAPH_RECT.height
						);
					_currentDrag.startDrag(true, rect);
					break;
				case _controlPost:
					_currentDrag = _controlPost;
					rect = new Rectangle(
						0, 
						-this.y - BezierGraph.PERCENT_RECT.top, 
						BezierGraph.GRAPH_RECT.width - this.x, 
						BezierGraph.GRAPH_RECT.height
					);
					_currentDrag.startDrag(true, rect);
					break;
			}

			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			
			event.stopPropagation();
		}

		private function _onMouseMove(event:MouseEvent):void
		{
			if(_currentDrag == this)
			{
				if(Math.abs(this.y) < FIT_HEIGHT)
					this.y = 0;
				if(Math.abs(this.y - BezierGraph.PERCENT_RECT.height) < FIT_HEIGHT)
					this.y = BezierGraph.PERCENT_RECT.height;
			}
			
			graphics.clear();

			_drawLine(_main, _controlPre);
			_drawLine(_main, _controlPost);

			dispatchEvent(new Event(Event.CHANGE));

			event.updateAfterEvent();
		}

		private function _onMouseUp(event:MouseEvent):void
		{
			_currentDrag.stopDrag();
			
			if(_currentDrag == this)
			{
				if(Math.abs(this.y) < FIT_HEIGHT)
					this.y = 0;
				if(Math.abs(this.y - BezierGraph.PERCENT_RECT.height) < FIT_HEIGHT)
					this.y = BezierGraph.PERCENT_RECT.height;
			}

			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
		}

		private function _drawLine(p0:DisplayObject, p1:DisplayObject, color:uint = 0x5083fc):void
		{
			graphics.lineStyle(1, color);
			graphics.moveTo(p0.x, p0.y);
			graphics.lineTo(p1.x, p1.y);
			graphics.lineStyle();
		}
		
		public function updateControlPoint(mx:Number, my:Number):void
		{
			var rot:Number = Math.atan2(my-this.y, mx - this.x);
			rot = Math.max(-Math.PI/2, Math.min(Math.PI/2, rot));
			var t:Point = new Point(mx, my);
			var me:Point = new Point(this.x, this.y);
			
			var post:Point = Point.polar(Point.distance(t, me), rot);
			_controlPost.x = post.x;
			_controlPost.y = post.y;
			
			var pre:Point = Point.polar(Point.distance(t, me), rot - Math.PI);
			_controlPre.x = pre.x;
			_controlPre.y = pre.y;

			graphics.clear();
			
			_drawLine(_main, _controlPre);
			_drawLine(_main, _controlPost);
		}
		
	}
}