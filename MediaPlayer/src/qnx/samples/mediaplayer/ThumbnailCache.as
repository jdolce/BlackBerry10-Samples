package qnx.samples.mediaplayer
{
	import qnx.fuse.ui.utils.ImageCache;

	public class ThumbnailCache
	{
		
		private static var __cache:ImageCache;
		
		public static function getChache():ImageCache
		{
			if( __cache == null )
			{
				__cache = new ImageCache();
			}
			
			return( __cache );
		}

	}
}