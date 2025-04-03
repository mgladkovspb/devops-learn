import { check } from "k6";
import http from 'k6/http';

export default function() {
    var url = "http://192.168.1.108/";
    let res = http.get(url);
    check(res, {
        "is status 200": (r) => r.status === 200
    }, { my_tag: res.body },);
}