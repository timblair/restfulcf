<!--- -->
<fusedoc fuse="restfulcf/framework/core/cache/AbstractCache.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am the base of all response caches
	</responsibilities>
</fusedoc>
--->

<cfcomponent output="no">

	<cfset variables.default_timeout = createtimespan(0,0,30,0)>

	<cffunction name="init" access="public" returntype="restfulcf.framework.core.cache.AbstractCache" output="no" hint="Initialises this cache">
		<cfargument name="timeout" type="numeric" required="no" hint="The timespan to use as a default timeout">
		<!--- the base component is an 'abstract' cache and cannot be used as an actual implementation --->
		<cfif getmetadata(this).name EQ "restfulcf.framework.core.cache.AbstractCache">
			<cfthrow type="RESTfulCF.AbstractCache.CannotInitAbstractCache" message="The #getmetadata(this).name# component must be extended to provide a concrete cache implementation." detail="Extend this component and override the getKey, setKey and deleteKey functions.">
		</cfif>
		<cfif structkeyexists(arguments, "timeout")><cfset variables.default_timeout = arguments.timeout></cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="get" access="public" returntype="struct" output="no" hint="Get a response from the cache.  Returns a struct with up to two keys: `found` = true|false; `response` = the response object (will only exist if key is found)">
		<cfargument name="request" type="restfulcf.framework.core.Request" required="yes" hint="The request object to get a response for">
		<cfset var resp = { found = FALSE }>
		<cfset var cache_key = serialiseRequest(arguments.request)>
		<cfset var cache_data = getKey(cache_key)>
		<cfif len(cache_data)>
			<cfset resp.found = TRUE>
			<cfset resp.response = deserialiseResponse(cache_data, arguments.request)>
			<cfset resp.response.setCacheHit(TRUE)>
			<cfset resp.response.setCacheKey(cache_key)>
		</cfif>
		<cfreturn resp>
	</cffunction>
	<cffunction name="set" access="public" returntype="void" output="no" hint="Sets a key in the cache">
		<cfargument name="request" type="restfulcf.framework.core.Request" required="yes" hint="The request object to set a response for">
		<cfargument name="response" type="restfulcf.framework.core.Response" required="yes" hint="The response object to set">
		<!--- if the cache expiry stamp in the response is zero, use the default --->
		<cfset var exp = arguments.response.getCacheExpiry()>
		<cfif NOT exp><cfset exp = variables.default_timeout></cfif>
		<cfset setKey(
			key     = serialiseRequest(arguments.request),
			value   = serialiseResponse(arguments.response),
			expires = dateadd('s', round(exp * 86400), now())
		)>
	</cffunction>
	<cffunction name="delete" access="public" returntype="void" output="no" hint="Deletes a key from the cache">
		<cfargument name="request" type="restfulcf.framework.core.Request" required="yes" hint="The request object to delete the cached response for">
		<cfset deleteKey(serialiseRequest(arguments.request))>
	</cffunction>

	<cffunction name="serialiseRequest" access="private" returntype="string" output="no" hint="Builds a key from a request object">
		<cfargument name="request" type="restfulcf.framework.core.Request" required="yes" hint="The request object to build the cache key for">
		<cfset var args = []>
		<cfset var key  = []>
		<cfset var arg  = "">
		<!--- build the structure that will represent this request --->
		<cfset var params = {}>
		<cfset params['_verb'] = arguments.request.getRoute().getVerb()>
		<cfset params['_uri']  = arguments.request.getRoute().getURI()>
		<cfset params['_type'] = arguments.request.getResponseType()>
		<cfset structappend(params, arguments.request.getArguments())>
		<!--- build what is effectively an alpha-ordered query string of all params --->
		<cfset args = structkeyarray(params)>
		<cfset arraysort(args, "textnocase")>
		<cfloop array="#args#" index="arg"><cfset arrayappend(key, lcase(arg) & "=" & params[arg])></cfloop>
		<cfreturn arraytolist(key, "&")>
	</cffunction>

	<cffunction name="serialiseResponse" access="private" returntype="string" output="no" hint="Builds a cached response string from a response object">
		<cfargument name="response" type="restfulcf.framework.core.Response" required="yes" hint="The response object for serialisation">
		<cfset var resp = {
			status_code   = arguments.response.getStatusCode(),
			status_text   = arguments.response.getStatusText(),
			response_type = arguments.response.getResponseType(),
			response_uri  = arguments.response.getResponseURI(),
			response_body = arguments.response.getResponseBody(),
			response_file = arguments.response.getResponseFile()
		}>
		<cfreturn serializejson(resp)>
	</cffunction>
	<cffunction name="deserialiseResponse" access="private" returntype="restfulcf.framework.core.Response" output="no" hint="Builds a response object from a cached response string">
		<cfargument name="data" type="string" required="yes" hint="The string representation of the reponse to build in to a complete response object">
		<cfargument name="request" type="restfulcf.framework.core.Request" required="yes" hint="The request object that requested this cached response">
		<cfset var response = createobject("component", "restfulcf.framework.core.Response").init(arguments.request)>
		<cfset var resp = deserializejson(arguments.data)>
		<cfset response.setStatusCode(resp.status_code)>
		<cfset response.setStatusText(resp.status_text)>
		<cfset response.setResponseType(resp.response_type)>
		<cfset response.setResponseURI(resp.response_uri)>
		<cfset response.setResponseBody(resp.response_body)>
		<cfset response.setResponseFile(resp.response_file)>
		<cfset response.setCacheHit(TRUE)>
		<cfreturn response>
	</cffunction>


	<!--- THESE FUNCTIONS MUST BE IMPLEMENTED IN THE CONCRETE CACHE --->

	<cffunction name="getKey" access="public" returntype="string" output="no" hint="Gets the value for a given key from the cache">
		<cfargument name="key" type="string" required="yes" hint="The key to retrieve">
		<cfthrow type="RESTfulCF.AbstractCache.NotImplemented" message="The getKey() function must be implemented by #getmetadata(this).name#">
	</cffunction>
	<cffunction name="setKey" access="public" returntype="void" output="no" hint="Sets a given value for a given key in the cache">
		<cfargument name="key" type="string" required="yes" hint="The key to set">
		<cfargument name="value" type="string" required="yes" hint="The value to store">
		<cfargument name="expires" type="numeric" required="yes" hint="The cache expiry date time">
		<cfthrow type="RESTfulCF.AbstractCache.NotImplemented" message="The setKey() function must be implemented by #getmetadata(this).name#">
	</cffunction>
	<cffunction name="deleteKey" access="public" returntype="void" output="no" hint="Deletes a given key from the cache">
		<cfargument name="key" type="string" required="yes" hint="The key to delete">
		<cfthrow type="RESTfulCF.AbstractCache.NotImplemented" message="The deleteKey() function must be implemented by #getmetadata(this).name#">
	</cffunction>

</cfcomponent>
