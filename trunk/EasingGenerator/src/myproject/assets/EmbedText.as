package myproject.assets
{
	public class EmbedText
	{
		[Embed(source="BetweenAS3_Code.txt", mimeType="application/octet-stream")]
		public static const CODE_BETWEENAS3:Class;
		[Embed(source="Tweener_Code.txt", mimeType="application/octet-stream")]
		public static const CODE_TWEENER:Class;
		[Embed(source="KTween_Code.txt", mimeType="application/octet-stream")]
		public static const CODE_KTWEEN:Class;
		[Embed(source="TweenMax_Code.txt", mimeType="application/octet-stream")]
		public static const CODE_TWEENMAX:Class;
	}
}