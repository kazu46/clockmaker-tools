package myproject.preview
{
	import org.libspark.betweenas3.core.easing.IEasing;
	import org.libspark.betweenas3.tweens.ITween;

	/**
	 * IMonitorはITweenのプレビュー用のインターフェースです。
	 * @author yasu
	 * 
	 */
	public interface IMonitor
	{
		/**
		 * ITweenインスタンスを取得します。
		 * @return 
		 * 
		 */
		function get tween():ITween;
		
		/**
		 * トゥイーンを初期化します。
		 * @param ease イージング関数
		 * @param time 時間(秒)
		 * @param playFlag 自動再生させるかどうかの指定
		 */
		function initTween(ease:IEasing, time:Number, playFlag:Boolean):void;
	}
}