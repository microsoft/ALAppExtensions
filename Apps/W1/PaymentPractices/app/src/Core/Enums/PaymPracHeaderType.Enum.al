enum 686 "Paym. Prac. Header Type" implements PaymentPracticeDataGenerator
{
    Extensible = true;

    value(1; Vendor)
    {
        Implementation = PaymentPracticeDataGenerator = "Paym. Prac. Vendor Generator";
    }
    value(2; Customer)
    {
        Implementation = PaymentPracticeDataGenerator = "Paym. Prac. Cust. Generator";
    }
    value(3; "Vendor+Customer")
    {
        Implementation = PaymentPracticeDataGenerator = "Paym. Prac. CV Generator";
    }
}