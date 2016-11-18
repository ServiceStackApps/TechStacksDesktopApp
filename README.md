# TechStacks Desktop Cocoa OSX App

The TechStacks OSX Desktop App is built around 2 AutoQuery Services showing how much querying functionality [AutoQuery Services](https://github.com/ServiceStack/ServiceStack/wiki/Auto-Query) provides for free and how easy they are to call with [ServiceStack's new support for Swift and XCode](https://github.com/ServiceStack/ServiceStack/wiki/Swift-Add-ServiceStack-Reference).

Behind the scenes the TechStacks Desktop app is essentially powered withby these 2 AutoQuery Services:

```csharp
[Query(QueryTerm.Or)] //change from filtering (default) to combinatory semantics
public class FindTechStacks : QueryDb<TechnologyStack> {}

[Query(QueryTerm.Or)]
public class FindTechnologies : QueryDb<Technology> {}
```

Basically just a Request DTO telling AutoQuery what Table we want to Query and that we want to [change the default Search behavior](https://github.com/ServiceStack/ServiceStack/wiki/Auto-Query#changing-querying-behavior) to have **OR** semantics. We don't need to specify which properties we can query as the [implicit conventions](https://github.com/ServiceStack/ServiceStack/wiki/Auto-Query#implicit-conventions) automatically infer it from the table being queried.

The TechStacks Desktop UI is then built around these 2 AutoQuery Services allowing querying against each field and utilizing a common subset of the implicit conventions supported:

### Querying Technology Stacks

![TechStack Desktop Search Fields](https://raw.githubusercontent.com/ServiceStack/Assets/master/img/release-notes/techstacks-desktop-field.png)

### Querying Technologies

![TechStack Desktop Search Type](https://raw.githubusercontent.com/ServiceStack/Assets/master/img/release-notes/techstacks-desktop-type.png)

Like the TechStacks iOS App all Service Calls are maintained in a single [AppData.swift](https://github.com/ServiceStackApps/TechStacksDesktopApp/blob/master/src/TechStacksDesktop/AppData.swift) class and uses KVO bindings to update its UI which is populated from these 2 services below:

```swift
func searchTechStacks(_ query:String, field:String? = nil, operand:String? = nil) 
  -> Promise<QueryResponse<TechnologyStack>> {
    self.search = query

    let queryString = query.count > 0 && field != nil && operand != nil
        ? [createAutoQueryParam(field!, operand!): query]
        : ["NameContains":query, "DescriptionContains":query]

    let request = FindTechStacks<TechnologyStack>()
    return client.getAsync(request, query:queryString)
        .then { r -> QueryResponse<TechnologyStack> in
            self.filteredTechStacks = r.results
            return r
        }
}

func searchTechnologies(_ query:String, field:String? = nil, operand:String? = nil) 
  -> Promise<QueryResponse<Technology>> {
    self.search = query

    let queryString = query.count > 0 && field != nil && operand != nil
        ? [createAutoQueryParam(field!, operand!): query]
        : ["NameContains":query, "DescriptionContains":query]

    let request = FindTechnologies<Technology>()
    return client.getAsync(request, query:queryString)
        .then { r -> QueryResponse<Technology> in
            self.filteredTechnologies = r.results
            return r
        }
}

func createAutoQueryParam(field:String, _ operand:String) -> String {
    let template = autoQueryOperandsMap[operand]!
    let mergedField = template.replace("%", withString:field)
    return mergedField
}
```

Essentially employing the same strategy for both AutoQuery Services where it builds a query String parameter to send with the request. For incomplete queries, the default search queries both `NameContains` and `DescriptionContains` field conventions returning results where the Search Text is either in `Name` **OR** `Description` fields.
