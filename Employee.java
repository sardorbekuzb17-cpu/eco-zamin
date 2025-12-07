public class Employee {
    private String name;
    private double salary;
    private double taxRate;
    
    public Employee(String name, double salary, double taxRate) {
        this.name = name;
        this.salary = salary;
        this.taxRate = taxRate;
    }
    
    public double calculateNetSalary() {
        return salary - (salary * taxRate / 100);
    }
    
    public String getName() { return name; }
    public double getSalary() { return salary; }
    public double getTaxRate() { return taxRate; }
}