package myproject.preview
{
	import com.bit101.components.Label;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.core.easing.IEasing;
	import org.libspark.betweenas3.tweens.ITween;
	
	public class RotateMonitor extends Sprite
	{
		public static const PREVIEW_RECT:Rectangle = new Rectangle(0, 20, 50, 50);
		/**
		 * 新しい RotateMonitor インスタンスを作成します。
		 */
		public function RotateMonitor()
		{
			new Label(this, 0, 0, "Rotate");
			
			graphics.lineStyle(1, 0xB3B3B3);
			graphics.beginFill(0xE6E6E6);
			graphics.drawRect(PREVIEW_RECT.x, PREVIEW_RECT.y, PREVIEW_RECT.width, PREVIEW_RECT.height);
			
			_previewShape = new Shape();
			_previewShape.graphics.beginFill(0x555555);
			_previewShape.graphics.drawCircle(0, 0, 25);
			_previewShape.graphics.endFill();
			_previewShape.graphics.beginFill(0xEEEEEE);
			_previewShape.graphics.drawCircle(0, -15, 2);
			_previewShape.graphics.endFill();
			_previewShape.x = PREVIEW_RECT.x + PREVIEW_RECT.width/2 >> 0;
			_previewShape.y = PREVIEW_RECT.y + PREVIEW_RECT.height/2 >> 0;
			addChild(_previewShape);
			
			mouseChildren = false;
			mouseEnabled = false;
		}
		
		private var _tween:ITween;
		private var _previewShape:Shape;
		/**
		 * @inheritDoc
		 */
		public function get tween():ITween
		{
			return _tween;
		}
		/**
		 * @inheritDoc
		 */
		public function initTween(ease:IEasing, time:Number, playFlag:Boolean):void
		{
			if(_tween) _tween.stop();
			// トゥイーンを作成
			_tween = BetweenAS3.tween(_previewShape, {rotation:360}, {rotation:0}, time, ease);
			_tween.stopOnComplete = false;
			if(playFlag) _tween.play();
		}
	}
}