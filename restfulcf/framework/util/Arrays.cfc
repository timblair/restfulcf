<!--- -->
<fusedoc fuse="restfulcf/framework/util/Arrays.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		I am a collection of functions which provide generic CF array manipulation methods.
	</responsibilities>
</fusedoc>
--->

<cfcomponent displayname="Arrays" output="no" hint="This is a collection of functions which provide generic CF array functions.">

	<cffunction name="join" access="public" returntype="array" output="no" hint="Joins two arrays together">
		<cfargument name="first" type="array" required="yes" hint="The first array to join">
		<cfargument name="second" type="array" required="yes" hint="The second array join">
		<cfset var i = 0>
		<cfloop from="1" to="#arraylen(arguments.second)#" index="i">
			<cfset arrayappend(arguments.first, arguments.second[i])>
		</cfloop>
		<cfreturn arguments.first>
	</cffunction>

	<cffunction name="split" access="public" returntype="array" output="no" hint="Splits a single array in two based on the number of elements required in the first.">
		<cfargument name="arr" type="array" required="yes" hint="The array to split">
		<cfargument name="cnt" type="numeric" required="yes" hint="The number of elements required in the first result array">
		<cfset var res = [[], []]>
		<cfset var i = 0>
		<cfloop from="1" to="#arguments.cnt#" index="i">
			<cfif arraylen(arguments.arr)>
				<cfset arrayappend(res[1], arguments.arr[1])>
				<cfset arraydeleteat(arguments.arr, 1)>
			</cfif>
		</cfloop>
		<cfset res[2] = arguments.arr>
		<cfreturn res>
	</cffunction>

	<cffunction name="merge" access="public" returntype="array" output="no" hint="Merges two arrays of structures together based on the value of a given key (lower value = earlier in the array).">
		<cfargument name="left" type="array" required="yes" hint="The first array to merge">
		<cfargument name="right" type="array" required="yes" hint="The second array merge">
		<cfargument name="key" type="string" required="yes" hint="The structure key to use for ordering - can be a function name to call if the array data items are component instances">
		<cfset var res = []>
		<cfset var dir = "">
		<cfset var l_key = "">
		<cfset var r_key = "">
		<!--- loop over both arrays, adding to the results based on the lower of the two array HEADs --->
		<cfloop condition="arraylen(arguments.left) AND arraylen(arguments.right)">
			<!--- default merge direction --->
			<cfset dir = "left">
			<!--- check for a structure item or a custom function for the left-hand node --->
			<cfif structkeyexists(arguments.left[1], arguments.key) AND NOT iscustomfunction(arguments.left[1][arguments.key])>
				<cfset l_key = arguments.left[1][arguments.key]>
			<cfelse><cfinvoke component="#arguments.left[1]#" method="#arguments.key#" returnvariable="l_key"></cfif>
			<!--- check for a structure item or a custom function for the right-hand node --->
			<cfif structkeyexists(arguments.right[1], arguments.key) AND NOT iscustomfunction(arguments.right[1][arguments.key])>
				<cfset r_key = arguments.right[1][arguments.key]>
			<cfelse><cfinvoke component="#arguments.right[1]#" method="#arguments.key#" returnvariable="r_key"></cfif>
			<!--- change the merge order if need be --->
			<cfif l_key GT r_key><cfset dir = "right"></cfif>
			<cfset arrayappend(res, arguments[dir][1])>
			<cfset arraydeleteat(arguments[dir], 1)>
		</cfloop>
		<!--- if there are any items left in either array, just stick them on the end --->
		<cfif arraylen(arguments.left)><cfset res = join(res, arguments.left)></cfif>
		<cfif arraylen(arguments.right)><cfset res = join(res, arguments.right)></cfif>
		<cfreturn res>
	</cffunction>

	<cffunction name="mergeSort" access="public" returntype="array" output="no" hint="Performs a merge sort on an array of structures based on the value of a given key (lower value = earlier in the array).">
		<cfargument name="arr" type="array" required="yes" hint="The array of structures to merge sort">
		<cfargument name="key" type="string" required="yes" hint="The structure key to use for ordering">
		<cfset var lft = []>
		<cfset var rgt = []>
		<cfset var spl = []>
		<!--- if we've less than two elements then there's nothing to sort --->
		<cfif arraylen(arguments.arr) LTE 1><cfreturn arguments.arr></cfif>
		<!--- split the array in two and recursively merge sort those bits --->
		<cfset spl = split(arguments.arr, ceiling(arraylen(arguments.arr)/2))>
		<cfset lft = mergeSort(spl[1], arguments.key)>
		<cfset rgt = mergeSort(spl[2], arguments.key)>
		<!--- merge the two parts back together in order and return --->
		<cfreturn merge(lft, rgt, arguments.key)>
	</cffunction>

	<cffunction name="slice" access="public" returntype="array" output="no" hint="Slices an array (returns a sub-section of the array).  Kinda like the LIMIT clause of a SQL statement.">
		<cfargument name="arr" type="array" required="yes" hint="The array to slice">
		<cfargument name="start" type="numeric" required="no" default="1" hint="The first result to return">
		<cfargument name="limit" type="numeric" required="no" default="#arraylen(arguments.arr)#" hint="The max number of results to return">
		<cfset var slice = []>
		<cfset var i = 0>
		<cfloop from="#arguments.start#" to="#arguments.start + arguments.limit - 1#" index="i">
			<cfif i GT arraylen(arguments.arr)><cfbreak></cfif>
			<cfif i GTE 1><cfset arrayappend(slice, arguments.arr[i])></cfif>
		</cfloop>
		<cfreturn slice>
	</cffunction>

	<cffunction name="switch" access="public" returntype="array" output="no" hint="Reverses an array">
		<cfargument name="arr" type="array" required="yes" hint="The array to reverse">
		<cfset var rev = []>
		<cfset var i = "">
		<cfloop from="#arraylen(arguments.arr)#" to="1" step="-1" index="i">
			<cfset arrayappend(rev, arguments.arr[i])>
		</cfloop>
		<cfreturn rev>
	</cffunction>

</cfcomponent>
