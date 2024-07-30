xquery version "3.1";

module namespace nical="https://eNahar.org/ns/ical/nical";

import module namespace roaster="http://e-editiones.org/roaster";
import module namespace cal-util     = "http://enahar.org/ns/ical/util" at "../modules/cal-util.xqm";

declare namespace fhir   = "http://hl7.org/fhir";

declare variable $nical:data-perms := "rwxrwxr-x";
declare variable $nical:data-group := "spz";
declare variable $nical:perms      := "rwxr-xr-x";
declare variable $nical:cals       := "/db/apps/eNaharData/data/calendars";
declare variable $nical:history    := "/db/apps/eNaharHistory/data/Cals";
declare variable $nical:schedule-base := "/db/apps/eNaharData/data/schedules";

declare function nical:update-ical($request as map(*)){
    let $user := sm:id()//sm:real/sm:username/string()
    let $collection := $request?parameters?collection
    let $payload := $request?body/node()
    (: let $stored := xmldb:store($config:page-root, $user || '-todos.xml' , $payload) :)
    return <stored>{$stored}</stored>
};

(:~
 : GET: enahar/icals/{uuid}
 : get cal by id
 : 
 : @param $id  uuid
 : 
 : @return <cal/>
 :)
declare function nical:read-ical($request as map(*)) as item()
{
    let $realm  := $request?parameters?realm
    let $loguid := $request?parameters?loguid
    let $lognam := $request?parameters?lognam
    let $uuid   := $request?parameters?id
    let $cals := collection($nical:cals)/cal[id[@value=$uuid]]
    return
        if (count($cals)=1)
        then $cals
        else  error(404, 'icals: uuid not valid.')
};

(:~
 : GET: enahar/ical?query
 : get cal owner
 :
 : @param $owner   string
 : @param $group   string
 : @param $active  boolean
 : @return bundle of <cal/>
 :)
declare function nical:search-ical($request as map(*)){
    let $user   := sm:id()//sm:real/sm:username/string()
    let $realm  := $request?parameters?realm
    let $loguid := $request?parameters?loguid
    let $lognam := $request?parameters?lognam
    let $elems  := $request?parameters?_elements
    let $owner  := $request?parameters?owner
    let $group  := $request?parameters?group
    let $active := $request?parameters?active
    let $oref := concat('metis/practitioners/', $owner)
    let $coll := collection($nical:cals)
    let $hits0 := if ($owner != '')
        then $coll/cal[owner/reference[@value=$oref]][active[@value=$active]]
        else $coll/cal[owner/group[@value=$group]][active[@value=$active]]

    let $sorted-hits :=
        for $c in $hits0
        order by lower-case($c/owner/display/@value/string())
        return
            if (string-length($elems)>0)
            then
                <cal>
                    {$c/id}
                    {$c/owner}
                </cal>
            else $c
    return
        cal-util:resources2Bundle($sorted-hits)
};