### Performance

The API endpoint relies on data from two sources: the database and an external API. Since the external API updates its data daily, we can persist its data in our database and use a periodic job to synchronize the database with the external API. This approach eliminates the need for expensive HTTP calls on every request to the endpoint, significantly improving performance and reliability.

By consolidating all required data into the database, we can execute a single or a few SQL queries to retrieve the data, delegating filtering, sorting, and aggregation logic to the database. Leveraging the database for these operations ensures high performance, as databases are optimized for such tasks. Additionally, this opens up opportunities for further optimization through techniques like adding indexes or refining SQL queries.

For the primary query, I chose to use plain SQL instead of ActiveRecord. This decision was driven by two factors: ease of expression for complex queries and performance considerations. Writing the query in plain SQL allows me to avoid instantiating model objects, which can result in significant time savings, especially when fetching a large number of records. However, this approach has trade-offs: plain SQL is less elegant and less flexible compared to using an ORM like ActiveRecord.

There are additional opportunities to enhance performance through advanced database techniques, such as:
- **Denormalization**: Reducing the need for joins by restructuring data to minimize relational dependencies.
- **Index Optimization**: Adding and fine-tuning indexes to speed up query execution.
- **Query Optimization**: Analyzing and tweaking the SQL query to ensure PostgreSQL generates an efficient execution plan.

### Code Decomposition

The solution is composed of a few key components: 

1. **Service Object**: Handles retrieving recommended cars for users from the external API.  
2. **Periodic Job**: Ensures that data from the external API is periodically synchronized with our database.  
3. **Finder Object**: Responsible for fetching the relevant data from the database and preparing it for the API endpoint response.  

The **Finder Object** could be further refined by separating its responsibilities into two distinct components:
- A query layer dedicated to interacting with the database.
- A serializer layer focused on transforming the data into the desired format.

However, I chose not to implement this decomposition at this stage to avoid over-engineering the solution prematurely. This allows us to iterate based on actual needs and complexity as the system evolves.

### Test Coverage

I included a single request spec file, as it tests the entire system in an integration style. This approach ensures that the solution is verified holistically, covering how the components interact to deliver the desired outcomes. I focused on covering all major cases to provide a robust baseline for testing.

That said, there is room for improvement by expanding the test suite. Additional cases could be added to cover edge scenarios and edge conditions more thoroughly. Furthermore, individual unit tests for service objects and jobs could be introduced to validate their functionality in isolation. This would enhance test coverage and make debugging easier by pinpointing issues within specific components.
