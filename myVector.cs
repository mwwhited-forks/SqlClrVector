using System;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Linq;
using System.Globalization;

[Serializable]
[SqlUserDefinedType(Format.UserDefined, IsByteOrdered = true, MaxByteSize = -1)]
public class Vector : INullable, IBinarySerialize
{
    private double[] _values;

    // Default constructor
    public Vector()
    {
        _values = Array.Empty<double>();
    }

    public bool IsNull { get; private set; }

    public static Vector Null
    {
        get
        {
            var vector = new Vector { IsNull = true };
            return vector;
        }
    }

    // Parse from a comma-delimited string or a simple JSON-like format
    public static Vector Parse(SqlString input)
    {
        if (input.IsNull || string.IsNullOrWhiteSpace(input.Value))
            return Null;

        var vector = new Vector();
        string inputValue = input.Value.Trim();

        try
        {
            if (inputValue.StartsWith("[") && inputValue.EndsWith("]"))
            {
                // Remove initial and final brackets
                string trimmedInput = inputValue.Substring(1, inputValue.Length - 2);

                // Split elements by commas and convert them to double
                vector._values = trimmedInput
                    .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(v => double.Parse(v, CultureInfo.InvariantCulture))
                    .ToArray();
            }
            else
            {
                // if it is not JSON-like, interpret as a comma separated list
                vector._values = inputValue
                    .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(v => double.Parse(v, CultureInfo.InvariantCulture))
                    .ToArray();
            }
        }
        catch (FormatException)
        {
            throw new ArgumentException("Invalid input format.");
        }

        vector.IsNull = false;
        return vector;
    }

    public override string ToString()
    {
        if (_values == null || _values.Length == 0)
            return "[]";

        // Format values and join them in a single line
        var formattedValues = _values
            .Select(v => v.ToString("e7", CultureInfo.InvariantCulture)) // Always use '.' as separator
            .ToArray();

        return "[" + string.Join(",", formattedValues) + "]";
    }

    // Methods for binary serialization (IBinarySerialize)
    public void Read(System.IO.BinaryReader reader)
    {
        int length = reader.ReadInt32();
        _values = new double[length];
        for (int i = 0; i < length; i++)
        {
            _values[i] = reader.ReadDouble();
        }
    }

    public void Write(System.IO.BinaryWriter writer)
    {
        writer.Write(_values.Length);
        foreach (var value in _values)
        {
            writer.Write(value);
        }
    }

    // Function to calculate distance between two vectors
    public static double VectorDistance(string distanceMetric, Vector vector1, Vector vector2)
    {
        if (vector1 == null || vector2 == null || vector1._values.Length != vector2._values.Length)
        {
            throw new ArgumentException("Vectors must be non-null and of the same length.");
        }

        distanceMetric = distanceMetric.ToLower();

        switch (distanceMetric)
        {
            case "cosine":
                return CosineDistance(vector1._values, vector2._values);
            case "euclidean":
                return EuclideanDistance(vector1._values, vector2._values);
            case "dot":
                return -DotProduct(vector1._values, vector2._values);
            case "manhattan":
                return ManhattanDistance(vector1._values, vector2._values);
            default:
                throw new ArgumentException($"Unsupported distance metric: {distanceMetric}");
        }
    }

    // Distance methods and operations between vectors...
    private static double CosineDistance(double[] v1, double[] v2)
    {
        double dot = DotProduct(v1, v2);
        double norm1 = Math.Sqrt(DotProduct(v1, v1));
        double norm2 = Math.Sqrt(DotProduct(v2, v2));

        if (norm1 == 0 || norm2 == 0)
            return 1.0;

        return 1.0 - (dot / (norm1 * norm2));
    }

    private static double EuclideanDistance(double[] v1, double[] v2)
    {
        double sum = 0.0;
        for (int i = 0; i < v1.Length; i++)
        {
            double diff = v1[i] - v2[i];
            sum += diff * diff;
        }
        return Math.Sqrt(sum);
    }

    private static double DotProduct(double[] v1, double[] v2)
    {
        double result = 0.0;
        for (int i = 0; i < v1.Length; i++)
        {
            result += v1[i] * v2[i];
        }
        return result;
    }

    private static double ManhattanDistance(double[] v1, double[] v2)
    {
        double distance = 0.0;
        for (int i = 0; i < v1.Length; i++)
        {
            distance += Math.Abs(v1[i] - v2[i]);
        }
        return distance;
    }
}
