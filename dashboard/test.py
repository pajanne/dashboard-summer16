import datapull as d

filename = input("Enter the name of the .csv file you wish to pull data from (including file extension):")
sequences = d.pull_data(filename)

print(filename, 'has', len(sequences), 'sequences.')
