xquery version "3.1";

module namespace cal-util = "http://enahar.org/ns/ical/util";

declare namespace html="http://www.w3.org/1999/xhtml";
declare namespace fhir = "http://hl7.org/fhir";


declare function cal-util:resources2Bundle(
      $resources as item()*
    )
{
    let $uuid := concat('b-',util:uuid())
    let $total := count($resources)
    return
    <Bundle xmlns="http://hl7.org/fhir" xml:id="{$uuid}">
        <id value="{$uuid}"/>
        <meta>
            <versionId value="0"/>
        </meta>
        <type value="searchset"/>
        <total value="{$total}"/>
    {
        for $r in $resources
        let $url := cal-util:fullUrl($r)
        return
            <entry xmlns="http://hl7.org/fhir">
                <fullUrl value="{$url}"/>
                <resource>{ $r }</resource>
            </entry>
    }
    </Bundle>
};

declare %private function cal-util:fullUrl($resource as item()) as xs:string
{
    string-join(('http://spz.uk-koeln.de','exist/apps','ical',local-name($resource),$resource/id/@value),'/')    
};