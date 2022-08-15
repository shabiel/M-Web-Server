%weburl ;YottaDB/CJE -- URL Matching routine;Jun 20, 2022@14:48
 ;
 ; This routine is used to map URLs to entry points under
 ; the URLMAP entry point.
 ;
URLMAP ;
 ;;GET ping ping^%webapi
 ;;GET /r/{routine?.1""%25"".32AN} R^%webapi
 ;;GET /test/xml xml^%webapi
 ;;GET /test/empty empty^%webapi
 ;;GET test/customerror customerr^%webapi
 ;;GET test/error ERR^%webapi
 ;;POST test/post POSTTEST^%webapi
 ;;GET test/utf8/get utf8get^%webapi
 ;;POST test/utf8/post utf8post^%webapi
 ;;zzzzz
 ;
 ; Copyright 2019 Christopher Edwards
 ; Copyright 2019 Sam Habiel
 ; Copyright 2022 YottaDB LLC
 ;
 ;Licensed under the Apache License, Version 2.0 (the "License");
 ;you may not use this file except in compliance with the License.
 ;You may obtain a copy of the License at
 ;
 ;    http://www.apache.org/licenses/LICENSE-2.0
 ;
 ;Unless required by applicable law or agreed to in writing, software
 ;distributed under the License is distributed on an "AS IS" BASIS,
 ;WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ;See the License for the specific language governing permissions and
 ;limitations under the License.
