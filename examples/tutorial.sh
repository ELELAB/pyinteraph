#!/bin/bash

# These first lines are prepared for a local installation PyInteraph.
# Please modify them accordingly to your installation.

export PYTHONPATH=$PYTHONPATH:../test/lib/python/
export PYINTERAPH=../test/pyinteraph/
export PATH=$PATH:$PYINTERAPH

# The PyInteraph package works through two main front-end scripts: pyinteraph and filter_graph.
# pyinteraph performs the analysis of structural ensembles for salt-bridges, hydrogen bonds and 
# hydrophobic interactions. The output files are a text file, which can be plotted on the 3D
# structure of proteins using the interactions_plotter PyMOL plugin (and PyMOL of course), and
# a graph .dat file. This is just the adjacency matrix of the IIN graph, and is a symmetric 
# square matrix format with space-separated numbers. 
# The graph file can be later processed using the filter_graph tool.

# pyinteraph
# ==========
#
# pyinteraph computes intra- or intermolecular protein interactions on ensembles of structures.
# It basically supports three main types of interactions: salt-bridges, hydrophobic and hydrogen bonds.
# The program requires as input at least two files:

# - a topology file (GRO, PDB, ...)
# - a trajectory file (XTC, DCD, PDB, ...)
# 
# The topology file contains the definition of the structure(s) whose atomic coordinates are specified
# in the trajectory file. Topology and trajectory file are required to have the same number of atoms,
# in the same order as well. 
# 
# The reference file (PDB) is optional. It is the structure that is taken as reference when writing output
# files. This file is especially important to supply information which is not explicitly declared in the 
# topology file, such as chains definition (which for instance are not present in GRO files) and 
# biologically-relevant residue numbering. The reference file must have the same order and residue sequence
# as the topology file, although the number of atoms may differ (i.e. it can be without hydrogens).
# It must also include heteroatoms and ligands, if present, in the same order as the topology file.

traj="traj.xtc"
top="sim.prot.gro"
ref="sim.prot.A.pdb"

# pyinteraph then must know which analysis have to be performed on the trajectory. This is performed using the flags:
# 
#   -b, --salt-bridges    Analyze salt-bridges
#   -f, --hydrophobic     Analyze hydrophobic clusters
#   -y, --hydrogen-bonds  Analyze hydrogen bonds
#   -p, --potential       Calculate knowledge-based potential pseudo-energy
# 
# you can require one or more of these analyses at the same time. For instance:

pyinteraph -s $top -t $traj -r $ref -b --sb-graph sb-graph.dat

# just analyzes salt-bridges, and

pyinteraph -s $top -t $traj -r $ref -y --hb-graph hb-graph.dat -f --hc-graph hc-graph.dat 

# calculates both hydrophobic interactions and hydrogen bonds.
# 
# The each interaction type, the following options are available:
# 
# salt bridges
# ------------
# 
#   --sb-co SB_CO, --sb-cutoff                    Distance cut-off for side-chain interaction.
# It is expressed in A. Two charged groups are considered as forming a salt-bridge if at least 
# one of the distances between two atoms belonging to them are at a distance lesser than SB_CO.
# 
#   --sb-perco SB_PERCO, --sb-persistence-cutoff  Minimum persistence for interactions
# It is expressed in %, and ranges from 0 to 100. Only write in the outputs those interactions whose persistence value is
# > SB_PERCO.
# 
#   --sb-dat                                      Output file name for the salt-bridges analysis
# 
#   --sb-graph SB_GRAPH                           Output file name for the sb-IIN 
# 
#   --sb-cg-file CGS_FILE                         Input (optional): charge groups definitions file
# By default, it is loaded from the $PYINTERAPH directory. A customized version can be supplied using
# this option.
# 
#   --sb-mode {different_charge,same_charge,all}  Interactions mode
# pyinteraph can consider the distances between differently charged residues (default), 
# residues with the same charge or all of them.
# 
# hydrogen bonds
# --------------
# 
#   --hb-co HB_CO, --hb-cutoff HB_CO  Acceptor-hydrogen distance cut-off.
#   --hb-ang HB_ANGLE, --hb-angle     Donor-H-acceptor angle cut-off.
# An hydrogen bond is identified if acceptor-hydrogen distance <= HB_CO 
# AND Donor-H-acceptor angle >= HB_ANGLE
# 
#   --hb-dat HB_DAT       Output file name for the hydrogen bonds analysis
# 
#   --hb-graph HB_GRAPH   Output file name for hb-IIN
# 
#   --hb-perco HB_PERCO   Minimum persistence for hydrogen bonds
# It is expressed in %, and ranges from 0 to 100. Only write in the outputs those interactions whose 
# persistence value is > HB_PERCO.
# 
#   --hb-class {all,mc-mc,mc-sc,sc-sc,custom}  Class of hydrogen bonds to analyse
#   --hb-custom-group-1 HB_GROUP1              Custom group 1 for hydrogen bonds calculation
#   --hb-custom-group-2 HB_GROUP2              Custom group 2 for hydrogen bonds calculation
# By default, pyinteraph will consider all the donor-acceptor atoms in the protein structures.
# However, the user can choose to only analyze mainchain-mainchain, mainchain-sidechains, sidechains-sidechains
# or custom groups hydrogen bonds. If the latter option is defined, users are required to supply two custom groups
# (which may also be superimposable) defined using the MDAnalysis selection algebra.  This also make it possible
# for instance to compute the hydrogen bonds between a protein and heteromolecules.
# 
#   --hb-ad-file HBS_FILE  File containing hydrogen bonds donor and acceptor atoms definitions.
# By default, it is loaded from the $PYINTERAPH directory. A customized version can be supplied using
# this option.
# 
# hydrophobic clusters
# --------------------
# 
#   --hc-co HC_CO, --hc-cutoff HC_CO    Distance cut-off for side-chain interaction
# It is expressed in A. Two residues are considered as interacting if the centers of mass of their side-chains 
# are no more than HC_CO A afar.
# 
#   --hc-perco HC_PERCO, --hc-persistence-cutoff HC_PERCO    Minimum persistence for interactions
# It is expressed in %, and ranges from 0 to 100. Only write in the dat output those interactions whose
# persistence value is > HB_PERCO.
# 
#   --hc-residues HC_RESLIST            Comma-separated list of hydrophobic residues 
# default: ALA,VAL,LEU,ILE,PHE,PRO,TRP,MET
# 
#   --hc-dat HC_DAT       Output file for hydrophobic interactions
# 
#   --hc-graph HC_GRAPH   Output file for hc-IIN
# 
#   --ff-masses           Force field containing mass information for several force-fields. 
# A force-field name can be specified to assign the correct masses to the atoms.
# This is espcially important for the hydrophobic clusters analysis which relies on centers of mass.
# It is especially important for united-atoms force-fields such as gromos.
# Each entry corresponds to a JSON-formatted file saved under the $PYINTERAPH/ff_masses directory
# and slightly hand-modified to include terminals and few special cases.
# New files can be generated from GROMACS force-field definitions, if need be, using the parse_masses
# script.
# 
# Knowledge-based potential calculation
# -------------------------------------
# 
#   --kbp-ff KBP_FF, --force-field KBP_FF   Statistical potential definition file.
#   --kbp-atomlist KBP_ATOMLIST     Ordered, force-field specific list of atom names.
# By default, it is loaded from the $PYINTERAPH directory. 
# 
#   --kbp-dat KBP_DAT       Output file for the the side-chains interaction energies
#                         
#   --kbp-graph KBP_GRAPH   Output file for the side-chains interactions energy in weighted adjacency matrix format
# 
#   --kbp-kbt KBP_KBT     kb*T value used in the inverse-boltzmann relation for the knowledge-based potential
# Default: 1.0
# 

pyinteraph -s $top -t $traj -r $ref -p --kbp-graph kbp-graph.dat

# filter_graph
# ============
# 
# The filter_graph script works on adjacency matrix files, such as as those outputted from the previously
# explained analyses. The script is designed to:
#
# 1) estimate significance threshold for the graph and use it to filter it. 
# This is performed by computing, for each persistence value,
# the size of the maximum connected component of the graph. The obtained plot usually has a sigmoidal shape 
# for globular proteins and the central flex point can be used as the significance threhsold. 
# This procedure is similar to what is performed in the Protein Structure Network analysis [ref].

filter_graph -d hc-graph.dat -c clusters_sizes.dat -p clusters_plot.pdf

# 2) It is also possible to try and fit the curve to a sigmoid curve  y = m / (1 +exp(k*(x-x0))) + n
# and try to identify the flexus point by solving the second derivative. However, this is not 
# guaranteed to work, depending on how off are the default parameters for the function
# (starting guesses can be supplied manually) and how well the solution converges.
# Once the persistence threshold has been assessed, the user is able to filter the graph by removing 
# all the edges with persistence lower than the desired threshold. This is performed with option -t:

threshold=20.0
filter_graph -d hc-graph.dat -o hc-graph-filtered.dat -t $threshold
filter_graph -d hb-graph.dat -o hb-graph-filtered.dat -t $threshold
filter_graph -d sb-graph.dat -o sb-graph-filtered.dat -t $threshold

# The output is a graph adjacency matrix that contains the persistence values as weights.

# 2) Filter and combine graphs, obtaining the macro-IIN.
# It is also possible to supply more than one input graph to filter_graph (multiple -d options).
# In this case, the program first filters each graph using the given threshold, if supplied.
# Then the graphs are combined so that an edge is generated if it is present in at least 
# one of the graphs, thus generating the macro-IIN. 
# The output graph is unweighted (all edges have weight 1). It is also possible to 
# supply a weight matrix (-w option) of the same size and shape as the macro-IIN (one value
# per residue pair). In this case, the edges of the macro-IIN are weighted according to the
# input matrix.

filter_graph -d hc-graph-filtered.dat -d hb-graph-filtered.dat -d sb-graph-filtered.dat -o macro-IIN-weighted.dat -w kbp-graph.dat 
filter_graph -d hc-graph-filtered.dat -d hb-graph-filtered.dat -d sb-graph-filtered.dat -o macro-IIN.dat

