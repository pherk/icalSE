xquery version "3.1";

module namespace nauth="https://eNahar.org/ns/ical/nauth";

import module namespace config="https://eNahar.org/ns/ical/config" at 'config.xqm';
import module namespace roaster="http://e-editiones.org/roaster";
import module namespace errors="http://e-editiones.org/roaster/errors";

declare function nauth:login(
        $request as map(*)
    ) as map(*)
{
    let $lll:= util:log-app("ERROR","exist.core", $request)
    let $user := $request?body?user
    return
    if (string-length($user)>0)
    then roaster:response( 200,
            map {
                "user": $user,
                "groups": ["dba", "spz"],
                "dba": true(),
                "domain" : "spz"
            })
    else
            error($errors:UNAUTHORIZED, "Wrong user or password", map {
                "user": $user,
                "domain": "guest"
            })
};

declare function nauth:logout(
        $request as map(*)
    ) as map(*)
{
    roaster:response( 200,
        map {
            "success": true()
        })
};
