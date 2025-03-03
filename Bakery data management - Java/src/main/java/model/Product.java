package model;


/**
 * Represents a product.
 */
public class Product {
    private int id;
    private String name;
    private int price;
    private int stock;

    public Product(){

    }

    public Product(int id, String name, int price, int stock){
        super();
        this.id = id;
        this.name = name;
        this.price = price;
        this.stock = stock;
    }


    public Product(String name, int price, int stock){
        super();
        this.name = name;
        this.price = price;
        this.stock = stock;
    }


    public Product(int id){
        super();
        this.id = id;
    }

    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public int getPrice() {
        return price;
    }
    public void setPrice(int price) {
        this.price = price;
    }
    public int getStock() {
        return stock;
    }

    @Override
    public String toString() {
        return "Product{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", price=" + price +
                ", stock=" + stock +
                '}';
    }

    public void setStock(int stock) {
        this.stock = stock;
    }
}
