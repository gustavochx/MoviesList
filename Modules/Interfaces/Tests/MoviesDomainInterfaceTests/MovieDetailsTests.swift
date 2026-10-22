import MoviesDomainInterface
import Testing

@Suite struct MovieDetailsTests {
    @Test func valuesWithTheSameFieldsAreEqual() {
        #expect(MovieDetails.fixture() == MovieDetails.fixture())
    }

    @Test func castOrderIsPartOfEquality() {
        let first = CastMember.fixture(id: 1)
        let second = CastMember.fixture(id: 2)

        #expect(MovieDetails.fixture(cast: [first, second]) != MovieDetails.fixture(cast: [second, first]))
    }
}
