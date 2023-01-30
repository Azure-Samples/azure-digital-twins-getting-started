namespace NDJsonGenerator
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using Azure.DigitalTwins.Core.Serialization;
    using Helpers;

    public class Program
    {
        public static void Main(string[] args)
        {
            // Example usage
            Stream ndjsonStream = null;
            try
            {
                string header = "{\"fileVersion\": \"1.0.0\", \"author\": \"foobar\", \"organization\": \"contoso\"}";
                IEnumerable<string> models = DataGenerator.GenerateModels(10);
                IEnumerable<BasicDigitalTwin> twins = DataGenerator.GenerateTwins(10, 100);
                IEnumerable<BasicRelationship> relationships = DataGenerator.GenerateRelationships(100);

                ndjsonStream = NDJsonGenerator.GenerateNDJson(models, twins, relationships, header);
                Console.WriteLine(new StreamReader(ndjsonStream).ReadToEnd());
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
            }
            finally
            {
                if (ndjsonStream != null) ndjsonStream.Close();
            }
        }
    }
}
