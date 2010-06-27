package myproject.impl
{

	/**
	 * インスタンス破棄のインターフェースです。 
	 * @author yasu
	 * 
	 */
	public interface IDestroyable
	{
		/**
		 * メモリ解放のための、インスタンスの終了処理を実行します。
		 * イベントリスナーの解除し、保持しているインスタンスの参照をnullにします。
		 */
		function destroy():void;
	}
}