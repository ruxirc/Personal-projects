package model;

import java.time.LocalDateTime;

/**
 * Represents a bill record.
 */
public record Bill(int id, int orderId, double amount, LocalDateTime timestamp) {
    @Override
    public String toString() {
        return "Bill:" +
                "\nid=" + id +
                "\norderId=" + orderId +
                "\namount=" + amount +
                "\ntimestamp=" + timestamp + "\n\n";
    }
}
