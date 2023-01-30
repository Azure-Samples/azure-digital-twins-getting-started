namespace NDJsonGenerator
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Text;
    using System.Text.Json;
    using Azure.DigitalTwins.Core.Serialization;

    public class NDJsonGenerator
    {
        private const string HeaderSection = "{\"Section\": \"Header\"}";
        private const string ModelsSection = "{\"Section\": \"Models\"}";
        private const string TwinsSection = "{\"Section\": \"Twins\"}";
        private const string RelationshipsSection = "{\"Section\": \"Relationships\"}";
        private const string DefaultHeader = "{\"fileVersion\": \"1.0.0\", \"author\": \"authorName\", \"organization\": \"organization\"}";

        public static Stream GenerateNDJson(IEnumerable<string> models, IEnumerable<BasicDigitalTwin> twins, IEnumerable<BasicRelationship> relationships, string header = "")
        {
            var stream = new MemoryStream();
            var writer = new StreamWriter(stream, Encoding.UTF8);

            writer.WriteLine(HeaderSection);
            if (String.IsNullOrEmpty(header)) writer.WriteLine(DefaultHeader);
            else writer.WriteLine(header);

            if (models != null)
            {
                writer.WriteLine(ModelsSection);
                foreach (var model in models)
                {
                    var sanitizedModel = model.Replace(Environment.NewLine, String.Empty);
                    writer.WriteLine(sanitizedModel);
                }
            }

            if (twins != null)
            {
                writer.WriteLine(TwinsSection);
                foreach (var twin in twins)
                {
                    string sanitizedTwin = JsonSerializer.Serialize(twin, twin.GetType()).Replace(Environment.NewLine, String.Empty);
                    writer.WriteLine(sanitizedTwin);
                }
            }

            if (relationships != null)
            {
                writer.WriteLine(RelationshipsSection);
                foreach (var relationship in relationships)
                {
                    string sanitzedRelationship = JsonSerializer.Serialize(relationship, relationship.GetType()).Replace(Environment.NewLine, String.Empty);
                    writer.WriteLine(sanitzedRelationship);
                }
            }

            writer.WriteLine(); // Bug: BulkAPI requires newline at the end of the ndjson file

            writer.Flush();
            stream.Seek(0, SeekOrigin.Begin); // Set seek head to begining of stream to return ready to read stream

            return stream;
        }
    }
}