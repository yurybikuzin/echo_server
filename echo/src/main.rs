use hyper::server::conn::AddrStream;
use hyper::{Body, Request, Response, Server};
use hyper::service::{service_fn, make_service_fn};
use futures::future::{self, Future};

type BoxFut = Box<dyn Future<Item=Response<Body>, Error=hyper::Error> + Send>;

use serde::{Serialize};
struct EchoResponse<'a> {
    remote_addr: &'a std::net::SocketAddr,
    method: &'a hyper::Method,
    uri: &'a hyper::Uri,
    version: hyper::Version,
    headers: &'a hyper::HeaderMap,
}

use std::collections::HashMap;
use serde::ser::{Serializer, SerializeStruct};
impl<'a> Serialize for EchoResponse<'a> {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        // 2 is the number of fields in the struct.
        let mut state = serializer.serialize_struct("EchoResponse", 5)?;

        let method = format!("{:?}", self.method);
        state.serialize_field("method", &method)?;

        let uri = format!("{:?}", self.uri);
        state.serialize_field("uri", &uri)?;

        let remote_addr = format!("{:?}", self.remote_addr);
        state.serialize_field("remote_addr", &remote_addr)?;

        let version = format!("{:?}", self.version);
        state.serialize_field("version", &version)?;

        let mut headers = HashMap::<String, String>::new();
        for (key, value) in self.headers.iter() {
            let value = value.to_str().unwrap();
            headers.insert(format!("{}", key), format!("{}", value));
        }
        let json_str = serde_json::to_string(&headers).unwrap();
        let headers: HashMap<String, String> = serde_json::from_str(&json_str).unwrap();
        state.serialize_field("headers", &headers)?;

        state.end()
    }
}

fn debug_request<'a>(req: Request<Body>, remote_addr: &'a std::net::SocketAddr) -> BoxFut {
    let response = EchoResponse  {
        remote_addr,
        uri: req.uri(),
        method: req.method(),
        version: req.version(),
        headers: req.headers(),
    };
    let body_str = serde_json::to_string_pretty(&response).unwrap();
    let response = Response::new(Body::from(body_str));
    Box::new(future::ok(response))
}

fn main() {

    // This is our socket address...
    let addr = ([0, 0, 0, 0], 8000).into();

    // A `Service` is needed for every connection.
    let make_svc = make_service_fn(|socket: &AddrStream| {
        let remote_addr = socket.remote_addr();
        service_fn(move |req: Request<Body>| { 
            debug_request(req, &remote_addr)
        })
    });

    let server = Server::bind(&addr)
        .serve(make_svc)
        .map_err(|e| eprintln!("server error: {}", e));

    println!("Running server on {:?}", addr);

    // Run this server for... forever!
    hyper::rt::run(server);
}
