package myproject.ui
{
	import assets.Header;
	
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	/**
	 * ヘッダーUIです。
	 * @author yasu
	 * 
	 */
	public class HeaderUI extends UIComponent
	{
		/**
		 * 新しい HeaderUI インスタンスを作成します。
		 */
		public function HeaderUI()
		{
			var mc:Header = new Header();
			addChild(mc);
			
			mc.close_btn.addEventListener(MouseEvent.CLICK, _onClick);
			mc.bg_mc.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			
			mc.bg_mc.doubleClickEnabled = true;
			mc.bg_mc.addEventListener(MouseEvent.DOUBLE_CLICK, _onDoubleClick);
		}

		private function _onDoubleClick(event:MouseEvent):void
		{
			EasingGenerator.instance.changeContainer();
		}

		private function _onMouseDown(event:MouseEvent):void
		{
			this.stage.nativeWindow.startMove();
		}

		private function _onClick(event:MouseEvent):void
		{
			this.stage.nativeWindow.close();
		}
	}
}