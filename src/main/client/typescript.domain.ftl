[#-- @ftlvariable name="types_in_use" type="String[]" --]

[#import "_macros.ftl" as global/]

[#macro printType type]
  [#if type.type??]
    ${global.convertType(type.type, "ts")}[#if type.typeArguments?has_content]<[#list type.typeArguments as typeArgument][@printType typeArgument/][#sep], [/#sep][/#list]>[/#if][#if type.extends??] extends [#list type.extends as extends][@printType extends/][#sep], [/#sep][/#list][/#if][#t]
  [#else]
    ${type.name}[#if type.extends??] extends [#list type.extends as extends][@printType extends/][#sep], [/#sep][/#list][/#if][#t]
  [/#if]
[/#macro]

[#if domain_item.description??]${domain_item.description}[/#if][#t]
[#if domain_item.fields??]
export class [@printType domain_item/] {
  [#list domain_item.fields?keys?sort as fieldName]
  [#assign field = domain_item.fields[fieldName]/]
  [#if field.description??]${field.description}[/#if][#t]
  [#if field.anySetter?? && field.anySetter]
  [${global.scrubName(fieldName)}: string]: any; // Any other fields
  [#else]
  ${global.scrubName(fieldName)}?: [@printType field/];
  [/#if]
  [/#list]
}
[#else]
export enum ${domain_item.type} {
  [#list domain_item.enum as value]
    [#if global.needsConverter(domain_item)]
  ${value.name} = "${(value.args![])[0]!value.name}"[#sep],[/#sep]
    [#else]
  ${value.name!value}[#sep],[/#sep]
    [/#if]
  [/#list]
}
[/#if]

export default ${domain_item.type};
