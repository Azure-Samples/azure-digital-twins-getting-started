using Microsoft.Azure.Amqp.Framing;
using System;
using System.Collections.Generic;
using System.Text;

namespace TwinUpdatesSample.Dto
{
    public class Room
    {
        public string id { get; set; }
        public double temperature { get; set; } = -99;
        public double humidity { get; set; } = -99;
    }
}
