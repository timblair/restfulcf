<!--- -->
<fusedoc fuse="restfulcf/framework/util/XML.cfc" language="ColdFusion" specification="2.0">
	<responsibilities>
		Conversion of XML to useable structure/array.
	</responsibilities>
</fusedoc>
--->

<cfcomponent output="no">

	<cffunction name="toStruct" access="public" returntype="any" output="no" hint="A very simple functino for converting an XML document to a simple combination of structures and arrays.">
		<cfargument name="xml" type="xml" required="yes" hint="The XML to convert to a structure, either as an XML string or node object">
		<cfargument name="depth" type="numeric" required="no" default="999" hint="How deep in to the XML structure should we go?">
		<cfargument name="include_attr" type="boolean" required="no" default="TRUE" hint="Should XML attributes also be included in the returned structure?">
		<cfargument name="include_root" type="boolean" required="no" default="TRUE" hint="Should the root node be included?">
		<cfset var local = { xml_str = {} }>
		<cfset local.root = xmlparse(arguments.xml).xmlroot>
		<cfif arraylen(local.root.xmlchildren) AND arguments.depth GTE 1>
			<cfloop array="#local.root.xmlchildren#" index="local.child">
				<cfset local.child_str = toStruct(local.child, arguments.depth-1, arguments.include_attr, FALSE)>
				<cfif structkeyexists(local.xml_str, local.child.xmlname)>
					<cfif NOT isarray(local.xml_str[local.child.xmlname])>
						<cfset local.orig_val = local.xml_str[local.child.xmlname]>
						<cfset local.xml_str[local.child.xmlname] = [local.orig_val]>
						<cfif arguments.include_attr>
							<cfset local.orig_attr = local.xml_str[local.child.xmlname & "::attributes"]>
							<cfset local.xml_str[local.child.xmlname & "::attributes"] = [local.orig_attr]>
						</cfif>
					</cfif>
					<cfset arrayappend(local.xml_str[local.child.xmlname], local.child_str)>
					<cfif arguments.include_attr>
						<cfset arrayappend(local.xml_str[local.child.xmlname & "::attributes"],  local.child.xmlattributes)>
					</cfif>
				<cfelse>
					<cfset local.xml_str[local.child.xmlname] = local.child_str>
					<cfif arguments.include_attr>
						<cfset local.xml_str[local.child.xmlname & "::attributes"] = local.child.xmlattributes>
					</cfif>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset local.xml_str = local.root.xmltext>
		</cfif>
		<cfif arguments.include_root>
			<cfset local.rooted_xml = {}>
			<cfset local.rooted_xml[local.root.xmlname] = local.xml_str>
			<cfif arguments.include_attr>
				<cfset local.rooted_xml[local.root.xmlname & "::attributes"] = local.root.xmlattributes>
			</cfif>
			<cfset local.xml_str = local.rooted_xml>
		</cfif>
		<cfreturn local.xml_str>
	</cffunction>

</cfcomponent>
