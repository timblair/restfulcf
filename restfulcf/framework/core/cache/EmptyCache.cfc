<!--- -->
<fusedoc fuse="restfulcf/framework/core/cache/EmptyCache.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a concrete implementation of an abstract cache which doesn't actually cache anything.
		This is the default cache instance for the framework.
	</responsibilities>
</fusedoc>
--->

<cfcomponent extends="restfulcf.framework.core.cache.AbstractCache" output="no">

	<cffunction name="getKey" access="public" returntype="string" output="no" hint="Get a response from the cache"><cfreturn ""></cffunction>
	<cffunction name="setKey" access="public" returntype="string" output="no" hint="Sets a given value for a given key in the cache"></cffunction>
	<cffunction name="deleteKey" access="public" returntype="void" output="no" hint="Deletes a given key from the cache"></cffunction>

</cfcomponent>
