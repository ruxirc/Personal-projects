package businessLogic.validators;

import model.Client;

public class ClientAgeValidator implements Validator<Client>{
    private static final int MIN_AGE = 16;
    private static final int MAX_AGE = 65;

    /**
     * Validates the age of a client.
     *
     * @param t the client to validate.
     * @throws IllegalArgumentException if the client's age is not within the valid range.
     */
    @Override
    public void validate(Client t) {

        if (t.getAge() < MIN_AGE || t.getAge() > MAX_AGE) {
            throw new IllegalArgumentException("The Age limit is not respected!");
        }

    }

}
