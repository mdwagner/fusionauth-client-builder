[#import "_macros.ftl" as global/]
require "json"
require "uri"
require "./rest_client"

#
# Copyright (c) 2018-2019, FusionAuth, All Rights Reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific
# language governing permissions and limitations under the License.
#

module FusionAuth
  #
  # This class is the the Crystal client library for the FusionAuth CIAM Platform {https://fusionauth.io}
  #
  # Each method on this class calls one of the APIs for FusionAuth.
  class FusionAuthClient
    property api_key : String,
             base_url : String,
             connect_timeout = 1000,
             read_timeout = 2000,
             tenant_id : String? = nil

    def initialize(@api_key, @base_url)
    end

    def set_tenant_id(@tenant_id)
    end

[#list apis as api]
    #
  [#list api.comments as comment]
    # ${comment}
  [/#list]
    #
  [#list api.params![] as param]
    [#if !param.constant??]
    # @param ${camel_to_underscores(param.name?replace("end", "_end"))} [${global.convertType(param.javaType, "crystal")}] ${param.comments?join("\n    #     ")}
    [/#if]
  [/#list]
    # @return [FusionAuth::ClientResponse] The ClientResponse object.
[#if api.deprecated??]
    # @deprecated ${api.deprecated?replace("{{renamedMethod}}", camel_to_underscores(api.renamedMethod!''))}
[/#if]
    def ${camel_to_underscores(api.methodName)}(${global.methodParameters(api, "crystal")})
      [#assign formPost = false/]
      [#list api.params![] as param]
        [#if param.type == "form"][#assign formPost = true/][/#if]
      [/#list]
      [#if formPost]
      body = {
        [#list api.params![] as param]
          [#if param.type == "form"]
        "${param.name}" => ${(param.constant?? && param.constant)?then("\""+param.value+"\"", param.name)},
          [/#if]
        [/#list]
      }
      [/#if]
      start[#if api.anonymous??]Anonymous[/#if].uri("${api.uri}")
      [#if api.authorization??]
          .authorization(${api.authorization?replace('encodedJWT', 'encoded_jwt')})
      [/#if]
      [#list api.params![] as param]
        [#if param.type == "urlSegment"]
          .url_segment(${(param.constant?? && param.constant)?then(param.value, camel_to_underscores(param.name))})
        [#elseif param.type == "urlParameter"]
          .url_parameter("${param.parameterName}", ${(param.constant?? && param.constant)?then(param.value, camel_to_underscores(param.name?replace("end", "_end")))})
        [#elseif param.type == "body"]
          .body_handler(FusionAuth::JSONBodyHandler.new(${camel_to_underscores(param.name)}))
        [/#if]
      [/#list]
      [#if formPost]
          .body_handler(FusionAuth::FormDataBodyHandler.new(body))
      [/#if]
          .${api.method}()
          .go()
    end

[/#list]
    #
    # Starts the HTTP call
    #
    # @return [RESTClient] The RESTClient
    #
    private def start
      startAnonymous.authorization(@api_key)
    end

    private def startAnonymous
      RESTClient.new(URI.parse(@base_url))
        .connect_timeout(@connect_timeout)
        .read_timeout(@read_timeout)
        .tap do |client|
          if !@tenant_id.nil?
            client.header("X-FusionAuth-TenantId", @tenant_id.not_nil!)
          end
        end
    end
  end
end
