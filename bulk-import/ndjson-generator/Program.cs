namespace Azure.DigitalTwins.Utilities
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using Azure.DigitalTwins.Core;
    using Azure.DigitalTwins.Utilities.Helpers;

    public class Program
    {
        public static void Main(string[] args)
        {
            string header = "{\"fileVersion\": \"1.0.0\", \"author\": \"foobar\", \"organization\": \"contoso\"}";
            IEnumerable<string> models = RandomNDJsonDataGenerator.GenerateModels(10);
            IEnumerable<BasicDigitalTwin> twins = RandomNDJsonDataGenerator.GenerateTwins(10, 100);
            IEnumerable<BasicRelationship> relationships = RandomNDJsonDataGenerator.GenerateRelationships(100);

            using (Stream ndjsonStream = NDJsonGenerator.GenerateNDJson(models, twins, relationships, header))
            {
                Console.WriteLine(new StreamReader(ndjsonStream).ReadToEnd());
                Console.ReadLine();
            }
        }
    }
}
