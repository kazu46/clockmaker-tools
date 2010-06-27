package myproject.data
{
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	
	import myproject.BezierPoint;
	import myproject.data.PresetData;
	
	import org.libspark.betweenas3.easing.Back;
	import org.libspark.betweenas3.easing.Bounce;
	import org.libspark.betweenas3.easing.Elastic;
	import org.libspark.betweenas3.easing.Expo;
	import org.libspark.betweenas3.easing.Linear;

	public class Preset
	{
		public static const presetArr:Array = [
			new PresetData("linear", Linear.easeNone, [
			{point: [0, 0], pre: null, post: [0.2, 0.2]},
			{point: [1, 1], pre: [0.8, 0.8], post: null},
			]),
			new PresetData("Expo In", Expo.easeIn, [
				{point:[0,0],pre:[0,0],post:[0.71,0]},
				{point:[1,1],pre:[0.84,0.01],post:[1,1]},
			]),
			new PresetData("Expo Out", Expo.easeOut, [
				{point:[0,0],pre:[0,0],post:[0.15,0.88]},
				{point:[1,1],pre:[0.21,1],post:[1,1]},
			]),
			new PresetData("Expo InOut", Expo.easeInOut, [
				{point:[0,0],pre:[0,0],post:[0.25,0]},
				{point:[0.5,0.5],pre:[0.42,0],post:[0.58,1]},
				{point:[1,1],pre:[0.75,1],post:[1,1]},
			]),
			new PresetData("Back In", Back.easeIn, [
				{point:[0,0],pre:[0,0],post:[0.18,0.02]},
				{point:[0.41,-0.1],pre:[0.16,-0.09],post:[0.7,-0.09]},
				{point:[1,1],pre:[0.85,0.34],post:[1,1]},
			]),
			new PresetData("Back Out", Back.easeOut, [
				{point:[0,0],pre:[0,0],post:[0.18,0.82]},
				{point:[0.59,1.1],pre:[0.35,1.11],post:[0.74,1.09]},
				{point:[1,1],pre:[0.9,1.01],post:[1,1]},
			]),
			new PresetData("Bounce In", Bounce.easeIn, [
				{point:[0,0],pre:[0,0],post:[0.04,0.04]},
				{point:[0.09,0],pre:[0.06,0.04],post:[0.16,0.09]},
				{point:[0.27,0],pre:[0.21,0.09],post:[0.41,0.4]},
				{point:[0.64,0],pre:[0.54,0.25],post:[0.78,0.78]},
				{point:[1,1],pre:[0.89,0.99],post:[1,1]},
			]),
			new PresetData("Bounce Out", Bounce.easeOut, [
				{point:[0,0],pre:[0,0],post:[0.09,0]},
				{point:[0.36,1],pre:[0.24,0.28],post:[0.45,0.78]},
				{point:[0.73,1],pre:[0.57,0.58],post:[0.81,0.91]},
				{point:[0.91,1],pre:[0.84,0.91],post:[0.95,0.98]},
				{point:[1,1],pre:[0.97,0.96],post:[1,1]},
			]),
			new PresetData("Elastic In", Elastic.easeIn, [
				{point:[0,0],pre:[0,0],post:[0.07,0.02]},
				{point:[0.25,-0.02],pre:[0.22,-0.02],post:[0.29,-0.02]},
				{point:[0.41,0.02],pre:[0.36,0.02],post:[0.46,0.02]},
				{point:[0.56,-0.05],pre:[0.51,-0.04],post:[0.64,-0.04]},
				{point:[0.71,0.12],pre:[0.66,0.12],post:[0.79,0.12]},
				{point:[0.86,-0.37],pre:[0.81,-0.36],post:[0.93,-0.36]},
				{point:[1,1],pre:[0.97,0.85],post:[1,1]},
			]),
			new PresetData("Elastic Out", Elastic.easeOut, [
				{point:[0,0],pre:[0,0],post:[0.05,0.25]},
				{point:[0.14,1.36],pre:[0.06,1.36],post:[0.19,1.36]},
				{point:[0.28,0.87],pre:[0.22,0.88],post:[0.34,0.88]},
				{point:[0.43,1.05],pre:[0.38,1.05],post:[0.47,1.05]},
				{point:[0.59,0.98],pre:[0.53,0.97],post:[0.65,0.98]},
				{point:[0.73,1.02],pre:[0.69,1.02],post:[0.8,1.02]},
				{point:[1,1],pre:[0.87,0.95],post:[1,1]},
			]),
			];

		[Bindable]
		public static var presetAC:ArrayCollection = new ArrayCollection(presetArr);
	}
}