<!---
Author: Anuj Gakhar (http://www.anujgakhar.com)
Copyright (c) 2011 Anuj Gakhar. 
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice,
the list of conditions and the following disclaimer.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

API Reference : http://www.pandastream.com/docs/api
--->

<cfcomponent name="PandaStreamAPI" hint="Interacts with pandastream API" output="false">
	<cfscript>
		variables.api_version = "/v2";	
		variables.instance = {};
	</cfscript>	
	
	<cffunction name="init" output="false" access="public" returntype="any" hint="Initialises the CFC">
		<cfargument name="accessKey" required="true" type="string" default="" />
		<cfargument name="secretKey" required="true" type="string" default="" />
		<cfargument name="host" required="true" type="string" default="api.pandastream.com" />
		<cfargument name="port" required="true" type="string" default="443" />
		<cfargument name="cloudId" required="true" type="string" default="" />
		<cfscript>
			setAuthDetails(arguments.accessKey, arguments.secretKey);
			setCloudId(arguments.cloudId);
			setEndPointUrl(arguments.host, arguments.port);
			variables.instance.host = arguments.host;
			return this;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setAuthDetails" output="false" access="private" returntype="void" hint="Set the PandaStream credentials">
    	<cfargument name="accessKey" type="string" required="true" default="" hint="The PandaStream access key"/>
		<cfargument name="secretKey" type="string" required="true" default="" hint="The PandaStream secret key"/>
		<cfscript>
			variables.instance.accessKey = arguments.accessKey;
			variables.instance.secretKey = arguments.secretKey;
		</cfscript>
    </cffunction>

    <cffunction name="setCloudId" output="false" access="private" returntype="void" hint="Set the CloudId">
    	<cfargument name="cloudId" type="string" required="false" default="" hint="The CloudId to be used"/>
    	<cfscript>
			variables.instance.cloudId = arguments.cloudId;
		</cfscript>
    </cffunction>

    <cffunction name="setEndPointUrl" output="false" access="private" returntype="void" hint="Set the endpoint for PandaStream API">
    	<cfargument name="host" type="string" required="false" default="api.pandastream.com" hint="The endpoint"/>
		<cfargument name="port" required="true" type="string" default="443" />
    	<cfscript>
			var protocol = "http";
			if(arguments.port eq "443"){
				protocol = "https";
			}
			variables.instance.endPointUrl = protocol & "://" & arguments.host &  variables.api_version;
		</cfscript>
    </cffunction>

	<cffunction name="getAccessKey" output="false" access="public" returntype="void" hint="Get the PandaStream access key">
		 <cfreturn variables.instance.accessKey />	
	</cffunction>
	
	<cffunction name="getSecretKey" output="false" access="public" returntype="void" hint="Get the PandaStream secret key">
		 <cfreturn variables.instance.secretKey />	
	</cffunction>	
	
	<cffunction name="getEndPointUrl" output="false" access="public" returntype="string" hint="Get the endpoint">
		 <cfreturn variables.instance.endPointUrl />
	</cffunction>	
	
	<cffunction name="getCloudId" output="false" access="public" returntype="string" hint="Get the CloudId">
		 <cfreturn variables.instance.cloudId />
	</cffunction>
	
	<cffunction name="get" access="public" output="false" hint="GET call to the API" returntype="struct">
		<cfargument name="path" required="true" default="" type="string" />
		<cfargument name="params" required="false" default="#structNew()#" type="struct" />
		<cfscript>
			return PandaRequest('GET', arguments.path, arguments.params);
		</cfscript>	
	</cffunction>	
	
	<cffunction name="post" access="public" output="false" hint="POST call to the API" returntype="struct">
		<cfargument name="path" required="true" default="" type="string" />
		<cfargument name="params" required="false" default="#structNew()#" type="struct" />
		<cfscript>
			return PandaRequest('POST', arguments.path, arguments.params);
		</cfscript>	
	</cffunction>
	
	<cffunction name="put" access="public" output="false" hint="PUT call to the API" returntype="struct">
		<cfargument name="path" required="true" default="" type="string" />
		<cfargument name="params" required="false" default="#structNew()#" type="struct" />
		<cfscript>
			return PandaRequest('PUT', arguments.path, arguments.params);
		</cfscript>	
	</cffunction>
	
	<cffunction name="delete" access="public" output="false" hint="DELETE call to the API" returntype="struct">
		<cfargument name="path" required="true" default="" type="string" />
		<cfargument name="params" required="false" default="#structNew()#" type="struct" />
		<cfscript>
			return PandaRequest('DELETE', arguments.path, arguments.params);
		</cfscript>	
	</cffunction>
	
	<cffunction name="PandaRequest" access="public" output="false" hint="Make the Call to the Panda API" returntype="struct">
		<cfargument name="method" type="string" required="false" default="GET" hint="The HTTP method to invoke"/>
		<cfargument name="path" required="true" default="" type="string" hint="The path bit" />
		<cfargument name="parameters" type="struct" required="false" default="#structNew()#" hint="A struct of HTTP URL parameters to send in the request"/>
		<cfargument name="timeout" type="numeric" required="false" default="120" hint="The default call timeout"/>
		
		<cfscript>
			var results = {error=false,response={},message="",responseheader={}};
			var HTTPResults = "";
			var stringToSign = "";
			var queryString = "";
			var timestamp = date_iso8601();
			var sortedParams = listSort(structKeyList(arguments.parameters), "textnocase");
			var paramtype = "URL";
			if(arguments.method eq "POST"){
				paramtype = "FORMFIELD";
			}
			
			queryString = "access_key=#variables.instance.accessKey#";
			queryString = ListAppend(queryString, "cloud_id=#variables.instance.cloudId#", "&");
			queryString = ListAppend(queryString, "timestamp=#rfc3986_encodedFormat(timestamp)#", "&");
			for(p in arguments.parameters){
				queryString = ListAppend(queryString, "#lcase(p)#=#rfc3986_encodedFormat(arguments.parameters[p])#", "&");
			}
			queryString = ListSort(queryString, "textnocase", "asc", "&");
			
			stringToSign = "#arguments.method#\n#variables.instance.host#\n#trim(arguments.path)#\n#queryString#";
			
			WriteDump(stringToSign);
		</cfscript>
		
		<cfhttp method="#arguments.method#"
				url="#variables.instance.endPointUrl#/#arguments.path#"
				charset="utf-8"
				result="HTTPResults"
				timeout="#arguments.timeout#">

			<cfhttpparam type="#paramtype#" name="access_key" value="#variables.instance.accessKey#" />
			<cfhttpparam type="#paramtype#" name="cloud_id" value="#variables.instance.cloudId#" />
			<cfhttpparam type="#paramtype#" name="timestamp" value="#timestamp#" />
			<cfloop collection="#arguments.parameters#" item="param">
				<cfhttpparam type="#paramType#" name="#lcase(param)#" value="#arguments.parameters[param]#" />
			</cfloop>
			<cfhttpparam type="#paramtype#" name="signature" value="#createSignature(stringToSign)#" />
		</cfhttp>
		
		<cfscript>
			if(structKeyExists(HTTPResults,"fileContent"))
			{
				results.response = HTTPResults.fileContent;
			} else {
				results.response = "";
			}
			results.responseHeader = HTTPResults.responseHeader;
			results.message = HTTPResults.errorDetail;
			if( len(HTTPResults.errorDetail) ){ results.error = true; }

			if( structKeyExists(HTTPResults.responseHeader, "content-type") AND
			    HTTPResults.responseHeader["content-type"] contains "application/json" AND
				isJson(HTTPResults.fileContent) ){
				results.response = DeserializeJson(HTTPResults.fileContent);
				if( NOT listFindNoCase("200,204",HTTPResults.responseHeader.status_code) ){
					results.error = true;
				}
			}
			return results;
		</cfscript>	
	</cffunction>
	
	<cffunction name="createSignature" returntype="any" access="private" output="false" hint="Create request signature">
		<cfargument name="stringToSign" type="any" required="true" />
		<cfscript>
			var fixedData = replace(arguments.stringToSign,"\n","#chr(10)#","all");
			return toBase64(HMAC_SHA256(variables.instance.secretKey,fixedData) );
		</cfscript>
	</cffunction>

	<cffunction name="HMAC_SHA256" returntype="binary" access="private" output="false" hint="">
		<cfargument name="signKey"     type="string" required="true" />
	   	<cfargument name="signMessage" type="string" required="true" />
	   	<cfscript>
			var jMsg = JavaCast("string",arguments.signMessage).getBytes("utf-8");
			var jKey = JavaCast("string",arguments.signKey).getBytes("utf-8");
			var key = createObject("java","javax.crypto.spec.SecretKeySpec").init(jKey,"HmacSHA256");
			var mac = createObject("java","javax.crypto.Mac").getInstance(key.getAlgorithm());
			mac.init(key);
			mac.update(jMsg);
			return mac.doFinal();
	   	</cfscript>
	</cffunction>
	
	<cffunction name="date_iso8601" returntype="string" access="private" output="false" hint="">
		<cfscript>
			var utcdate = DateConvert('local2utc', now());
			return dateformat(utcdate, "yyyy-mm-dd") & "T" & timeformat(utcdate, "HH:mm:ss") & "Z";
		</cfscript>	
	</cffunction>
	
	<cffunction name="rfc3986_encodedFormat" returntype="string" access="private" output="false" hint="">
		<cfargument name="stringToEncode" required="true" type="string" />
		<cfscript>
			var encoder = createObject("java","java.net.URLEncoder");
			return encoder.encode(stringToEncode, "utf-8").replace("+", "%20").replace("*", "%2A").replace("%7E", "~");
		</cfscript>	
	</cffunction>
</cfcomponent>