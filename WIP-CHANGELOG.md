### Fixed

- Elasticsearch SLM retention value conversion bug
- Elasticsearch slm now deletes excess snapshots also when none of them are older than the maximum age

### Changed

- Increased default active deadline for the slm job from 5 to 60 minutes
- Elasticsearch slm now deletes indices in bulk
