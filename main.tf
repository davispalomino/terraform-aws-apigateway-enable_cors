terraform {
  required_version = ">= 0.12.1"
}
resource "aws_api_gateway_method" "options" {
  count                   = "${length(var.resource)}"
  rest_api_id   = "${var.rest_api}"
  resource_id   =  "${var.resource[count.index]}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  count                   = "${length(var.resource)}"
  rest_api_id = "${var.rest_api}"
  resource_id =  "${var.resource[count.index]}"
  http_method = "${element(aws_api_gateway_method.options.*.http_method, count.index)}"

  type = "MOCK"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "options" {
  count                   = "${length(var.resource)}"
  rest_api_id = "${var.rest_api}"
  resource_id =  "${var.resource[count.index]}"
  http_method = "${element(aws_api_gateway_method.options.*.http_method, count.index)}"
  status_code = 200
    response_parameters = {
          "method.response.header.Access-Control-Allow-Headers" = true,
          "method.response.header.Access-Control-Allow-Methods" = true,
          "method.response.header.Access-Control-Allow-Origin"  = true,
          "method.response.header.Access-Control-Max-Age"       = true
    }
     depends_on = ["aws_api_gateway_method.options"]
}



resource "aws_api_gateway_integration_response" "options" {
  count                   = "${length(var.resource)}"
  rest_api_id = "${var.rest_api}"
  resource_id =  "${var.resource[count.index]}"
  http_method = "${element(aws_api_gateway_method.options.*.http_method, count.index)}"
  status_code = 200

  response_parameters = {
          "method.response.header.Access-Control-Allow-Headers" = "'Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key'",
          "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,HEAD,GET,POST,PUT,PATCH,DELETE'",
          "method.response.header.Access-Control-Allow-Origin"  = "'*'",
          "method.response.header.Access-Control-Max-Age"       = "'7200'"
  }
  depends_on = ["aws_api_gateway_integration.options","aws_api_gateway_method_response.options"]
}
