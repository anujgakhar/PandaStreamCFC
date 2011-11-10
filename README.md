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
	
### Listing your videos

To retrieve a list of all your videos simply do:
	
	panda.get('/videos.json');	
	
### Delete your videos

To delete a video:

		panda.delete('/videos/:id.json');	