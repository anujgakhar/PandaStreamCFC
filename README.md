PandaStream CFC
=================

This CFC provides an interface to the REST API of [Panda](http://pandastream.com), the online video encoding service.

Setup
-----
Pass in your auth credentials to the CFC's init() method and start using it.

	ACCESS_KEY = "access_key";
	SECRET_KEY = "secret_key";
	CLOUD_ID = "cloud_id";

	objPanda = createObject("com.anujgakhar.PandaStreamAPI").init(
		cloud_id="#CLOUD_ID#", 
		access_key="#ACCESS_KEY#", 
		secret_key="#SECRET_KEY#"
	);
	
### Sample GET Request

To retrieve a list of all your videos simply do:
	
	objPanda.get('/videos.json');	or
	objPanda.get('/videos/:id.json')
	
	
### Sample DELETE Request

To delete a video:

	objPanda.delete('/videos/:id.json');	
	
### Sample PUT Request

To update a Cloud:

	params = {};
	params.name = "updated_from_api";
	objPanda.put('/clouds/#CLOUD_ID#.json', params);
	
### Sample POST Request

To post a video:

	params = {};
	params.source_url = "http://example.com/path/to/video.mp4";
	newVideo = objPanda.post('/videos.json', params);	
	
	
	