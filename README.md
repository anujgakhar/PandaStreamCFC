PandaStream CFC
=================

This CFC provides an interface to the REST API of [Panda](http://pandastream.com), the online video encoding service.

Setup
-----
Pass in your auth credentials to the CFC's init() method and start using it.

	ACCESS_KEY = "access_key";
	SECRET_KEY = "secret_key";
	CLOUD_ID = "cloud_id";

	panda = createObject("PandaStreamAPI").init(
	cloud_id="#CLOUD_ID#", 
	access_key="#ACCESS_KEY#", 
	secret_key="#SECRET_KEY#"
	);
	
### Sample GET Request

To retrieve a list of all your videos simply do:
	
	panda.get('/videos.json');	or
	panda.get('/videos/:id.json')
	
	
### Sample DELETE Request

To delete a video:

	panda.delete('/videos/:id.json');	
	
### Sample PUT Request

To update a Cloud:

	params = {};
	params.name = "updated_from_api";
	panda.put('/clouds/#CLOUD_ID#.json', params);
	
### Sample POST Request

To post a video:

	params = {};
	params.source_url = "http://example.com/path/to/video.mp4";
	newVideo = panda.post('/videos.json', params);	
	
	
	