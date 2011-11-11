<cfcomponent name="panda" hint="Interacts with pandastream API">
<cfscript>
	variables.cloud_id = "";
	variables.access_key = "";
	variables.secret_key = "";
	variables.api_host = "api.pandastream.com";
	variables.api_port = "443";
	variables.api_version = "2";

	public any function init(string cloud_id = "", string access_key = "", string secret_key = "", string api_host = "api.pandastream.com", string api_port = "443"){
		variables.cloud_id = arguments.cloud_id;
		variables.access_key = arguments.access_key;
		variables.secret_key = arguments.secret_key;
		variables.api_host = arguments.api_host;
		variables.api_port = arguments.api_port;
		return this;
	}
	
	public function get(required string path, params = {}){
		return panda_http_request('GET', path, params);
	}
	
	public function post(required string path, params = {})
	{
		return panda_http_request('POST', path, params);
	}
	
	public function put(required string path, params = {}){
		return panda_http_request('PUT', path, params);
	}
	
	public function delete(required string path, params = {}){
		return panda_http_request('DELETE', path, params);
	}
	
	private any function panda_http_request(required string verb, required string path, params = {}){
		var timestamp = date_iso8601();
		var apiCall = "";
		var results = {};
		var paramtype = "url";
		if(arguments.verb eq "POST"){
			paramType = "formfield";
		}
		
		var httpService = new http();
		httpService.setUrl(api_url() & "#trim(path)#");
		httpService.setTimeOut(120);
		httpService.setMethod(arguments.verb);
		for(param in arguments.params){
			httpService.addParam(type="#paramtype#", name="#lcase(param)#", value="#arguments.params[param]#");
		}
		httpService.addParam(type="#paramtype#", name="access_key", value="#variables.access_key#");
		httpService.addParam(type="#paramtype#", name="cloud_id", value="#variables.cloud_id#");
		httpService.addParam(type="#paramtype#", name="timestamp", value="#timestamp#");
		if(arguments.verb neq "POST"){
			httpService.addParam(type="#paramtype#", name="signature", value="#rfc3986_encodedFormat(buildSignature(verb, trim(path), params, timestamp))#");
		} else {
			httpService.addParam(type="#paramtype#", name="signature", value="#buildSignature(verb, trim(path), params, timestamp)#");
		}	

		apiCall = httpService.send().getPrefix();	
		
		if(apiCall.statuscode EQ "200 OK" AND IsJson(apiCall.filecontent)){
			results.status = "ok";
			results.data = DeSerializeJson(apiCall.filecontent);
		} else if (apiCall.statuscode EQ "200 OK") {
			results.status = "ok";
			results.data = apiCall.filecontent;
		} else if (IsJson(apiCall.filecontent)) {
			results.status = "error";
			errorInfo = DeserializeJson(apiCall.filecontent);
			results.data = "#errorInfo.error#: #errorInfo.message#";
		} else {
			results.status = "error";
			results.data = apiCall.statuscode;
		}
		return results;
	}
	
	private string function api_base_path(){
		return "/v" & variables.api_version;
	}
	
	private string function api_url(){
		var protocol = "http";
		if(variables.api_port eq "443"){
			protocol = "https";
		} 
		return protocol & "://" & variables.api_host & api_base_path();
	}
	
	private string function buildSignature(required string verb, required string path, required struct params, required string timestamp)
	{
		var query_string = "";
		var string_to_sign = "";
		
		query_string = "access_key=#variables.access_key#";
		query_string = ListAppend(query_string, "cloud_id=#variables.cloud_id#", "&");
		query_string = ListAppend(query_string, "timestamp=#rfc3986_encodedFormat(arguments.timestamp)#", "&");
		for(p in arguments.params){
			query_string = ListAppend(query_string, "#lcase(p)#=#rfc3986_encodedFormat(params[p])#", "&");
		}
		
		query_string = ListSort(query_string, "textnocase", "asc", "&");
		
		string_to_sign = arguments.verb &  chr(10) & lcase(variables.api_host) & chr(10) & trim(arguments.path) & chr(10) & query_string;
		
		digest = hmac_sha256(variables.secret_key, string_to_sign);
		return tobase64(digest);
	}
	
	private binary function hmac_sha256(required string signKey, required string signMessage){
		 var jMsg = JavaCast("string",arguments.signMessage).getBytes("iso-8859-1");
		 var jKey = JavaCast("string",arguments.signKey).getBytes("iso-8859-1");
		 var key = createObject("java","javax.crypto.spec.SecretKeySpec");
		 var mac = createObject("java","javax.crypto.Mac");

		 key = key.init(jKey,"HmacSHA256");
		 mac = mac.getInstance("HmacSHA256");
		 mac.init(key);
		 mac.update(jMsg);
		 return mac.doFinal();
	}
	
	private datetime function date_iso8601(){
		var utcdate = DateConvert('local2utc', now());
		return dateformat(utcdate, "yyyy-mm-dd") & "T" & timeformat(utcdate, "HH:mm:ss") & "Z";
	}
	
	private string function rfc3986_encodedFormat(stringToEncode){
		var encoder = createObject("java","java.net.URLEncoder");
		return encoder.encode(stringToEncode, "utf-8").replace("+", "%20").replace("*", "%2A").replace("%7E", "~");
	}
</cfscript>
</cfcomponent>