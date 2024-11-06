# trie

Work in progress

(Current) test file author:
https://github.com/martinlindhe/wordlist_swedish

`crystal spec <specfile>`
`crystal build --release src/server.cr`

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     trie:
       github: petter-petersson/trie
   ```

2. Run `shards install`

## Usage

build and run the test server:
`crystal build --release src/server.cr && ./server`

run the test client:
`ruby client.rb`

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/trie/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Petter Peterson](https://github.com/petter-petersson) - creator and maintainer
