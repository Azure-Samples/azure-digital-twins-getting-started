namespace Azure.DigitalTwins.Utilities
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Text.Json;
    using Azure.DigitalTwins.Core;
    using Azure.DigitalTwins.Core.Serialization;

    public sealed class NDJsonGenerator
    {
        private const string headerSection = "{\"Section\": \"Header\"}";
        private const string modelsSection = "{\"Section\": \"Models\"}";
        private const string twinsSection = "{\"Section\": \"Twins\"}";
        private const string relationshipsSection = "{\"Section\": \"Relationships\"}";
        private const string defaultHeader = "{\"fileVersion\": \"1.0.0\", \"author\": \"authorName\", \"organization\": \"organization\"}";

        public static Stream GenerateNDJson(IEnumerable<string> models, IEnumerable<BasicDigitalTwin> twins, IEnumerable<BasicRelationship> relationships, string header = "")
        {
            var stream = new MemoryStream();
            var writer = new StreamWriter(stream, Encoding.UTF8);

            writer.WriteLine(headerSection);
            writer.WriteLine(string.IsNullOrEmpty(header) ? defaultHeader : header);

            models ??= Enumerable.Empty<string>();
            writer.WriteLine(modelsSection);
            foreach (var model in models)
            {
                var sanitizedModel = model.Replace(Environment.NewLine, string.Empty);
                writer.WriteLine(sanitizedModel);
            }

            twins ??= Enumerable.Empty<BasicDigitalTwin>();
            writer.WriteLine(twinsSection);
            foreach (var twin in twins)
            {
                string sanitizedTwin = JsonSerializer.Serialize(twin, twin.GetType()).Replace(Environment.NewLine, string.Empty);
                writer.WriteLine(sanitizedTwin);
            }

            relationships ??= Enumerable.Empty<BasicRelationship>();
            writer.WriteLine(relationshipsSection);
            foreach (var relationship in relationships)
            {
                string sanitzedRelationship = JsonSerializer.Serialize(relationship, relationship.GetType()).Replace(Environment.NewLine, string.Empty);
                writer.WriteLine(sanitzedRelationship);
            }

            writer.WriteLine();

            writer.Flush();
            stream.Seek(0, SeekOrigin.Begin);

            return stream;
        }
    }
}