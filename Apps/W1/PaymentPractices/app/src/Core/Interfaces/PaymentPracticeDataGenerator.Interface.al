interface PaymentPracticeDataGenerator
{
    /// <summary>
    /// Generates the data for the Payment Practice report from the source defined in the Header Type enum value.
    /// </summary>
    /// <param name="PaymentPracticeData">Generated data</param>
    /// <param name="PaymentPracticeHeader">Header to generate data for.</param>
    procedure GenerateData(var PaymentPracticeData: Record "Payment Practice Data"; PaymentPracticeHeader: Record "Payment Practice Header");
}