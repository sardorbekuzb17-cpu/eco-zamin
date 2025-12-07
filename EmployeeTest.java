public class EmployeeTest {
    public static void main(String[] args) {
        Employee emp = new Employee("Ali", 5000000, 12);
        
        System.out.println("Xodim: " + emp.getName());
        System.out.println("Asosiy oylik: " + emp.getSalary());
        System.out.println("Soliq foizi: " + emp.getTaxRate() + "%");
        System.out.println("Soliqdan keyingi oylik: " + emp.calculateNetSalary());
    }
}