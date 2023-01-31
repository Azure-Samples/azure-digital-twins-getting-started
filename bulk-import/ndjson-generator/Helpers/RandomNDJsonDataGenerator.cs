namespace Azure.DigitalTwins.Utilities.Helpers
{
    using System;
    using System.Collections.Generic;
    using System.Text.Json;
    using Azure.DigitalTwins.Core;

    public static class RandomNDJsonDataGenerator
    {
        private static readonly string modelsTemplate = "{{\"@id\":\"dtmi:com:microsoft:azure:iot:model{0};1\",\"@type\":\"Interface\",\"contents\":[{{\"@type\":\"Property\",\"name\":\"prop0\",\"schema\":\"string\"}},{{\"@type\": \"Component\",\"name\":\"Component1\",\"schema\":\"dtmi:com:microsoft:azure:iot:componentmodel;1\"}},{{\"@type\":\"Property\",\"name\":\"prop1\",\"schema\":\"string\"}},{{\"@type\":\"Relationship\",\"name\":\"has\",\"target\":\"dtmi:com:microsoft:azure:iot:model{1};1\",\"properties\":[{{\"@type\":\"Property\",\"name\":\"relationshipproperty1\",\"schema\":\"string\"}},{{\"@type\":\"Property\",\"name\":\"relationshipproperty2\",\"schema\":\"string\"}}]}}],\"description\":{{\"en\":\"This is the description of model\"}},\"displayName\":{{\"en\":\"This is the display name\"}},\"@context\":\"dtmi:dtdl:context;2\"}}" + Environment.NewLine;
        private static readonly string componentModel = $"{{ \"@id\": \"dtmi:com:microsoft:azure:iot:componentmodel;1\", \"@type\": \"Interface\", \"@context\": \"dtmi:dtdl:context;2\", \"displayName\": \"Component1\", \"contents\": [ {{ \"@type\": \"Property\", \"name\": \"ComponentProp1\", \"schema\": \"string\" }} ] }}" + Environment.NewLine;
        private static readonly string twinsTemplate = "{{\"$dtId\":\"twin{0}\",\"$metadata\":{{\"$model\":\"dtmi:com:microsoft:azure:iot:model{1};1\"}},\"prop0\":\"propertyValue0\",\"prop1\":\"propertyValue1\", \"Component1\":{{ \"$metadata\":{{ }}, \"ComponentProp1\": \"value\"}} }}" + Environment.NewLine;
        private static readonly string relationshipsTemplate = "{{\"$dtId\":\"twin{0}\",\"$relationshipId\":\"relationship\",\"$targetId\":\"twin{1}\",\"$relationshipName\":\"has\",\"relationshipProperty1\":\"propertyValue1\",\"relationshipProperty2\":\"propertyValue2\"}}" + Environment.NewLine;

        public static IEnumerable<string> GenerateModels(int numModels)
        {
            yield return componentModel;
            for (var i = 0; i < numModels; i++)
            {
                yield return string.Format(modelsTemplate, i, (i + 1) % numModels);
            }
        }

        public static IEnumerable<BasicDigitalTwin> GenerateTwins(int numModels, int numTwins)
        {
            for (var i = 0; i < numTwins; i++)
            {
                // If no models, use value of i. Else, cycle through models
                int modelId = numModels == 0 ? i : i % numModels;
                string twin = string.Format(twinsTemplate, i, modelId);
                yield return JsonSerializer.Deserialize<BasicDigitalTwin>(twin);
            }
        }

        public static IEnumerable<BasicRelationship> GenerateRelationships(int numRelationships)
        {
            for (var i = 0; i < numRelationships; i++)
            {
                string relationship = string.Format(relationshipsTemplate, i, (i + 1) % numRelationships);
                yield return JsonSerializer.Deserialize<BasicRelationship>(relationship);
            }
        }
    }
}
