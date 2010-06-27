package myproject.data
{
	import flash.geom.Point;
	
	import myproject.BezierPoint;
	
	import org.libspark.betweenas3.core.easing.IEasing;

	public class PresetData
	{
		public function PresetData(label:String, func:IEasing, data:Array)
		{
			this.label = label;  
			this.data = data;  
			this.func = func;
		}
		
		[Bindable]
		public var label:String;
		
		[Bindable]
		public var func:IEasing;
		
		[Bindable]
		public var data:Array;
		
	}
}