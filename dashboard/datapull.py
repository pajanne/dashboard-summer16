#The purpose of this script is to hold a function which receives a .csv filename, then returns a formatted list of sequences for use in graphs.

import csv

class Sequence:
    def __init__(self, institute, external, slxid, flowcellid,                  #Receive these values when an instance of the class is created
                lane, description, platform, runtype, cycles,
                billable, yield_, q30, acceptancedate, sequencingdate,
                publishingdate, billingdate, turnaroundtime):
                    self.institute = institute
                    self.external = external
                    self.slxid = slxid
                    self.flowcellid = flowcellid
                    self.lane = lane
                    self.description = description
                    self.platform = platform
                    self.runtype = runtype
                    self.cycles = cycles
                    self.billable = billable
                    self.yield_ = yield_
                    self.q30 = q30
                    self.acceptancedate = acceptancedate
                    self.sequencingdate = sequencingdate
                    self.publishingdate = publishingdate
                    self.billingdate = billingdate
                    self.turnaroundtime = turnaroundtime

def pull_data(csvDocument):
    #For each line of the csv document (below the column headings), create a Sequence and add it to a list
    with open(csvDocument) as csvfile:
        sequenceReader = csv.reader(csvfile, delimiter=',', quotechar='|')

        i = 0
        sequences = []

        for row in sequenceReader:
            if (i > 0):                                                         #Skip the first line which has column headings, not data
                strings = []
                for string in row:
                    strings.append(string[1:-1])                                #The 1:-1 removes quotation marks at the beginning/end of the string
                seq = Sequence(strings[0], strings[1], strings[2], strings[3],
                                strings[4], strings[5], strings[6], strings[7],
                                strings[8], strings[9], strings[10], strings[11],
                                strings[12], strings[13], strings[14], strings[15],
                                strings[16])
                sequences.append(seq)
            i += 1
    return sequences                                                            #Returns a list with all Sequences in the .csv file
