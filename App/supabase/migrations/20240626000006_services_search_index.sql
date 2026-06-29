-- Full-text search for services (name + description)

ALTER TABLE services
  ADD COLUMN IF NOT EXISTS search_vector tsvector
  GENERATED ALWAYS AS (
    to_tsvector(
      'english',
      coalesce(name, '') || ' ' || coalesce(description, '')
    )
  ) STORED;

CREATE INDEX IF NOT EXISTS idx_services_search_vector
  ON services USING GIN (search_vector);
