library(dplyr)
library(forestplot)
library(ggplot2)

base_data <- tibble::tibble(mean  = c(1.044,	1.003,	1.008,	1.019,
                                      1.188,	1.125,	1.103,	1.088,
                                      1.214,	1.121,	1.047,	1.029,
                                      1.369,	1.252,	1.162,	1.127,
                                      1.246,	1.136,	1.057,	1.037,
                                      1.357,	1.238,	1.158,	1.09,
                                      1.206,	1.362,	1.17,	1.096,
                                      1.285,	1.468,	1.272,	1.149,
                                      1.224,	1.137,	1.198,	1.141,
                                      1.485,	1.36,	1.382,	1.222),
                            
                            lower = c(0.986,	0.948,	0.953,	0.962,
                                      1.113,	1.056,	1.036,	1.023,
                                      1.147,	1.061,	0.99,	0.968,
                                      1.282,	1.174,	1.09,	1.054,
                                      1.177,	1.071,	0.996,	0.976,
                                      1.273,	1.161,	1.086,	1.023,
                                      0.997,	1.272,	1.109,	1.047,
                                      1.059,	1.367,	1.203,	1.095,
                                      1.074,	1.001,	1.058,	1.006,
                                      1.291,	1.187,	1.21,	1.072),
                            
                            upper = c(1.106,	1.06,	1.066,	1.079,
                                      1.267,	1.198,	1.174,	1.158,
                                      1.286,	1.186,	1.108,	1.094,
                                      1.463,	1.336,	1.238,	1.205,
                                      1.319,	1.205,	1.121,	1.103,
                                      1.446,	1.321,	1.235,	1.162,
                                      1.459,	1.457,	1.234,	1.149,
                                      1.559,	1.575,	1.345,	1.206,
                                      1.395,	1.291,	1.358,	1.295,
                                      1.707,	1.558,	1.579,	1.392),
                            
                            index = c(1,	2,	3,	4,
                                      5,	6,	7,	8,
                                      9,	10,	11,	12,
                                      13,	14,	15,	16,
                                      17,	18,	19,	20,
                                      21,	22,	23,	24,
                                      25,	26,	27,	28,
                                      29,	30,	31,	32,
                                      33,	34,	35,	36,
                                      37,	38,	39,	40),
                            
                            study = c("Crude Yost 1v5", "Crude Yost 2v5", "Crude Yost 3v5", "Crude Yost 4v5", 
                                      "Replication Yost 1v5", "Replication Yost 2v5", "Replication Yost 3v5", "Replication Yost 4v5", 
                                      "Crude NDI 1v5", "Crude NDI 2v5", "Crude NDI 3v5", "Crude NDI 4v5", 
                                      "Replication NDI 1v5", "Replication NDI 2v5", "Replication NDI 3v5", "Replication NDI 4v5",  
                                      "Crude SVI 1v5", "Crude SVI 2v5", "Crude SVI 3v5", "Crude SVI 4v5",  
                                      "Replication SVI 1v5", "Replication SVI 2v5", "Replication SVI 3v5", "Replication SVI 4v5", 
                                      "Crude Education 1v5", "Crude Education 2v5", "Crude Education 3v5", "Crude Education 4v5", 
                                      "Replication Education 1v5", "Replication Education 2v5", "Replication Education 3v5", "Replication Education 4v5", 
                                      "Crude ncome 1v5", "Crude Income 2v5", "Crude Income 3v5", "Crude Income 4v5",
                                      "Replication Income 1v5", "Replication Income 2v5", "Replication Income 3v5", "Replication Income 4v5"),
                            
                            OR = c("1.044",	"1.003",	"1.008",	"1.019",
                                   "1.188",	"1.125",	"1.103",	"1.088",
                                   "1.214",	"1.121",	"1.047",	"1.029",
                                   "1.369",	"1.252",	"1.162",	"1.127",
                                   "1.246",	"1.136",	"1.057",	"1.037",
                                   "1.357",	"1.238",	"1.158",	"1.09",
                                   "1.206",	"1.362",	"1.17",	"1.096",
                                   "1.285",	"1.468",	"1.272",	"1.149",
                                   "1.224",	"1.137",	"1.198",	"1.141",
                                   "1.485",	"1.36",	"1.382",	"1.222"),
                            
                            P = c("0.1420",	"0.9267",	"0.7786",	"0.5247",
                                  "<.0001",	"0.0002",	"0.0021",	"0.0076",
                                  "<.0001",	"<.0001",	"0.1043",	"0.3537",
                                  "<.0001",	"<.0001",	"<.0001",	"0.0005",
                                  "<.0001",	"<.0001",	"0.0668",	"0.2398",
                                  "<.0001",	"<.0001",	"<.0001",	"0.0079",
                                  "0.0539",	"<.0001",	"<.0001",	"<.0001",
                                  "0.0110",	"<.0001",	"<.0001",	"<.0001",
                                  "0.0024",	"0.0479",	"0.0045",	"0.0406",
                                  "<.0001",	"<.0001",	"<.0001",	"0.0026"))

crude_data <- tibble::tibble(mean  = c(1.044,	1.003,	1.008,	1.019,
                                      1.214,	1.121,	1.047,	1.029,
                                      1.246,	1.136,	1.057,	1.037,
                                      1.206,	1.362,	1.17,	1.096,
                                      1.224,	1.137,	1.198,	1.141),
                            
                            lower = c(0.986,	0.948,	0.953,	0.962,
                                      1.147,	1.061,	0.99,	0.968,
                                      1.177,	1.071,	0.996,	0.976,
                                      0.997,	1.272,	1.109,	1.047,
                                      1.074,	1.001,	1.058,	1.006),
                            
                            upper = c(1.106,	1.06,	1.066,	1.079,
                                      1.286,	1.186,	1.108,	1.094,
                                      1.319,	1.205,	1.121,	1.103,
                                      1.459,	1.457,	1.234,	1.149,
                                      1.395,	1.291,	1.358,	1.295),

                            index = c(1,	2,	3,	4,
                                      5,	6,	7,	8,
                                      9,	10,	11,	12,
                                      13,	14,	15,	16,
                                      17,	18,	19,	20),
                            
                            study = c("Crude Yost 1v5", "Crude Yost 2v5", "Crude Yost 3v5", "Crude Yost 4v5", 
                                      "Crude NDI 1v5", "Crude NDI 2v5", "Crude NDI 3v5", "Crude NDI 4v5", 
                                      "Crude SVI 1v5", "Crude SVI 2v5", "Crude SVI 3v5", "Crude SVI 4v5",  
                                      "Crude Education 1v5", "Crude Education 2v5", "Crude Education 3v5", "Crude Education 4v5", 
                                      "Crude Income 1v5", "Crude Income 2v5", "Crude Income 3v5", "Crude Income 4v5"),
                            
                            OR = c("1.044",	"1.003",	"1.008",	"1.019",
                                   "1.214",	"1.121",	"1.047",	"1.029",
                                   "1.246",	"1.136",	"1.057",	"1.037",
                                   "1.206",	"1.362",	"1.17",	"1.096",
                                   "1.224",	"1.137",	"1.198",	"1.141"),
                            
                            P = c("0.1420",	"0.9267",	"0.7786",	"0.5247",
                                  "<.0001",	"<.0001",	"0.1043",	"0.3537",
                                  "<.0001",	"<.0001",	"0.0668",	"0.2398",
                                  "0.0539",	"<.0001",	"<.0001",	"<.0001",
                                  "0.0024",	"0.0479",	"0.0045",	"0.0406"))

  
plot2 <- ggplot(crude_data, aes(y = index, x = mean)) +
  geom_point(shape = 18, size =5) +  
  geom_errorbarh(aes(xmin = lower, xmax = upper), height = 0.25) +
  geom_vline(xintercept = 1, color = "red", linetype = "dashed", cex = 1, alpha = 0.5) +
  ggtitle("Crude SDOH Odds Ratios and 95% CIs")+
  scale_y_continuous(name = "", breaks=1:20, labels = crude_data$study, trans = "reverse") +
  xlab("Odds Ratio (95% CI)") + 
  ylab(" ") + 
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black"),
        axis.text.y = element_text(size = 12, colour = "black"),
        axis.text.x.bottom = element_text(size = 12, colour = "black"),
        axis.title.x = element_text(size = 12, colour = "black"))
plot2

rep_data <- tibble::tibble(mean  = c(1.188,	1.125,	1.103,	1.088,
                                      1.369,	1.252,	1.162,	1.127,
                                      1.357,	1.238,	1.158,	1.09,
                                      1.285,	1.468,	1.272,	1.149,
                                      1.485,	1.36,	1.382,	1.222),
                            
                            lower = c(1.113,	1.056,	1.036,	1.023,
                                      1.282,	1.174,	1.09,	1.054,
                                      1.273,	1.161,	1.086,	1.023,
                                      1.059,	1.367,	1.203,	1.095,
                                      1.291,	1.187,	1.21,	1.072),
                            
                            upper = c(1.267,	1.198,	1.174,	1.158,
                                      1.463,	1.336,	1.238,	1.205,
                                      1.446,	1.321,	1.235,	1.162,
                                      1.559,	1.575,	1.345,	1.206,
                                      1.707,	1.558,	1.579,	1.392),
                            
                            index = c(1,	2,	3,	4,
                                      5,	6,	7,	8,
                                      9,	10,	11,	12,
                                      13,	14,	15,	16,
                                      17,	18,	19,	20),
                            
                            study = c("Replication Yost 1v5", "Replication Yost 2v5", "Replication Yost 3v5", "Replication Yost 4v5", 
                                      "Replication NDI 1v5", "Replication NDI 2v5", "Replication NDI 3v5", "Replication NDI 4v5",  
                                      "Replication SVI 1v5", "Replication SVI 2v5", "Replication SVI 3v5", "Replication SVI 4v5", 
                                      "Replication Education 1v5", "Replication Education 2v5", "Replication Education 3v5", "Replication Education 4v5", 
                                      "Replication Income 1v5", "Replication Income 2v5", "Replication Income 3v5", "Replication Income 4v5"),
                            
                            OR = c("1.188",	"1.125",	"1.103",	"1.088",
                                   "1.369",	"1.252",	"1.162",	"1.127",
                                   "1.357",	"1.238",	"1.158",	"1.09",
                                   "1.285",	"1.468",	"1.272",	"1.149",
                                   "1.485",	"1.36",	"1.382",	"1.222"),
                            
                            P = c("<.0001",	"0.0002",	"0.0021",	"0.0076",
                                  "<.0001",	"<.0001",	"<.0001",	"0.0005",
                                  "<.0001",	"<.0001",	"<.0001",	"0.0079",
                                  "0.0110",	"<.0001",	"<.0001",	"<.0001",
                                  "<.0001",	"<.0001",	"<.0001",	"0.0026"))

plot3 <- ggplot(rep_data, aes(y = index, x = mean)) +
  geom_point(shape = 18, size =5) +  
  geom_errorbarh(aes(xmin = lower, xmax = upper), height = 0.25) +
  geom_vline(xintercept = 1, color = "red", linetype = "dashed", cex = 1, alpha = 0.5) +
  scale_y_continuous(name = "", breaks=1:20, labels = rep_data$study, trans = "reverse") +
  ggtitle("Replication SDOH Odds Ratios and 95% CIs")+
  xlab("Odds Ratio (95% CI)") + 
  ylab(" ") + 
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black"),
        axis.text.y = element_text(size = 12, colour = "black"),
        axis.text.x.bottom = element_text(size = 12, colour = "black"),
        axis.title.x = element_text(size = 12, colour = "black"))
plot3