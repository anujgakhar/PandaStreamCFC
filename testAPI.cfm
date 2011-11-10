<cfscript>
	ACCESS_KEY = "access_key";
	SECRET_KEY = "secret_key";
	CLOUD_ID = "cloud_id";
	
	panda = createObject("PandaStreamAPI").init(
		cloud_id="#CLOUD_ID#", 
		access_key="#ACCESS_KEY#", 
		secret_key="#SECRET_KEY#"
		);
	
	// get a particular video
	//getOneVideo = panda.get('/videos/3db9ebf8a13173545e264a506d398896.json');
	//writeDump(getOneVideo);
	
	//get all videos
	getAllVideos = panda.get('/videos.json');
	swriteDump(getAllVideos);
	
	// post
	//params = {};
	//params.source_url = "http://example.com/path/to/video.mp4";
	//newVideo = panda.post('/videos.json', params);
	//writeDump(newVideo);
	
	// delete
	//deleteVideo = panda.delete('/videos/89902a3a1f9c9c725fade8c6b1185ec3.json');
	//writeDump(deleteVideo);

</cfscript>