package myproject.preview
{
	import com.bit101.components.Label;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.core.easing.IEasing;
	import org.libspark.betweenas3.tweens.ITween;

	public class MoveMonitor extends Sprite implements IMonitor
	{
		public static const PREVIEW_RECT:Rectangle = new Rectangle(0, 20, 400, 50);

		/**
		 * 新しい MoveMonitor インスタンスを作成します。
		 */
		public function MoveMonitor()
		{
			new Label(this, 0, 0, "Move");

			graphics.lineStyle(1, 0xB3B3B3);
			graphics.beginFill(0xE6E6E6);
			graphics.drawRect(PREVIEW_RECT.x, PREVIEW_RECT.y, PREVIEW_RECT.width, PREVIEW_RECT.height);
			graphics.endFill();

			graphics.lineStyle();
			graphics.beginFill(0xCCCCCC);
			graphics.drawCircle(PREVIEW_RECT.left + 24 + 1, PREVIEW_RECT.top + 24 + 2, 24);
			graphics.drawCircle(PREVIEW_RECT.right - 24 - 1, PREVIEW_RECT.top + 24 + 2, 24);
			
			_previewShape = new Shape();
			_previewShape.graphics.beginFill(0x555555)
			_previewShape.graphics.drawCircle(24, 24, 24);
			_previewShape.y = PREVIEW_RECT.y + 2;
			addChild(_previewShape);

			mouseChildren = false;
			mouseEnabled = false;
		}

		/**
		 * @inheritDoc
		 */
		public function get tween():ITween
		{
			return _tween;
		}

		private var _tween:ITween;
		private var _previewShape:Shape;

		/**
		 * @inheritDoc
		 */
		public function initTween(ease:IEasing, time:Number, playFlag:Boolean):void
		{
			if(_tween) _tween.stop();
			// トゥイーンを作成
			_tween = BetweenAS3.tween(_previewShape, {x: PREVIEW_RECT.right - _previewShape.width}, {x: PREVIEW_RECT.x}, time, ease);
			_tween.stopOnComplete = false;
			if(playFlag) _tween.play();
		}
	}
}